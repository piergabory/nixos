#!/usr/bin/env python3
"""Best-effort guard for local Nix-on-Droid builds; never activate or run GC.

Usage: python3 scripts/nix-droid-safe.py [plan|build|eval] [--package opencode-droid]
Logs, memory samples, and build results live in ~/.cache/nix-droid-safe/.
Requires Linux /proc, child-subreaper support, Python 3 and a local Nix store.
This is not a cgroup memory limit and cannot protect against SIGKILL or reboot.
"""
import argparse
import ctypes
from dataclasses import dataclass
import json
import os
from pathlib import Path
import resource
import signal
import subprocess
import sys
import time

MIB = 1024 * 1024
CACHE = Path.home() / ".cache/nix-droid-safe"
DEFAULT_TARGET = "nixOnDroidConfigurations.default.activationPackage"


def available():
    for line in Path('/proc/meminfo').read_text().splitlines():
        if line.startswith('MemAvailable:'):
            return int(line.split()[1]) * 1024
    raise RuntimeError('Cannot read MemAvailable; refusing unguarded build')


@dataclass(frozen=True)
class Process:
    pid: int
    ppid: int
    pgid: int
    sid: int
    started: int
    rss: int
    threads: int

    @property
    def identity(self):
        return self.pid, self.started


def read_process(pid, proc=Path('/proc')):
    # comm can contain spaces and parentheses. Fields start at state.
    fields = (proc / str(pid) / 'stat').read_text().rsplit(')', 1)[1].split()
    return Process(int(pid), int(fields[1]), int(fields[2]), int(fields[3]),
                   int(fields[19]), int(fields[21]) * os.sysconf('SC_PAGE_SIZE'),
                   int(fields[17]))


def processes():
    result = {}
    for entry in Path('/proc').iterdir():
        if not entry.name.isdigit():
            continue
        try:
            item = read_process(entry.name)
            result[item.pid] = item
        except (OSError, ValueError, IndexError):
            continue  # process exited or belongs to another Android app
    return result


class ProcessTree:
    """Follow descendants even across setsid(), reparenting, and PID reuse."""

    def __init__(self, root, watcher=None):
        self.root = root
        self.watcher = os.getpid() if watcher is None else watcher
        self.known = {root.identity}

    def sample(self, snapshot=None):
        snapshot = processes() if snapshot is None else snapshot
        selected = {
            p.pid: p for p in snapshot.values()
            if p.identity in self.known or p.ppid == self.watcher
        }
        # Session/group membership catches children if their immediate parent
        # exits between samples. Subreaper adoption covers new sessions too.
        for p in snapshot.values():
            if p.sid == self.root.sid or p.pgid == self.root.pgid:
                selected[p.pid] = p
        while True:
            added = {p.pid: p for p in snapshot.values()
                     if p.pid not in selected and p.ppid in selected}
            if not added:
                break
            selected.update(added)
        self.known = {p.identity for p in selected.values()}
        return selected

    def signal(self, sig):
        selected = self.sample()
        for p in selected.values():
            try:
                # Never signal a PID that has since been reused.
                if read_process(p.pid).identity == p.identity:
                    os.kill(p.pid, sig)
            except ProcessLookupError:
                pass
            except FileNotFoundError:
                pass


def enable_subreaper():
    # Orphaned grandchildren are adopted by this guard instead of escaping to
    # Android's init. This does not require root or writable cgroups.
    libc = ctypes.CDLL(None, use_errno=True)
    if libc.prctl(36, 1, 0, 0, 0) != 0:  # PR_SET_CHILD_SUBREAPER
        raise OSError(ctypes.get_errno(), 'Cannot enable child subreaper')


def limits():
    # Per-process, not aggregate. Keep it as an additional backstop; sampled
    # tree RSS and system MemAvailable handle the aggregate best-effort limit.
    resource.setrlimit(resource.RLIMIT_AS, (2048 * MIB, 2048 * MIB))
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    os.nice(10)


def stop(p, tree):
    # Builders may have their own process groups: kill the tracked tree, not
    # just killpg(nix.pid). Continue sampling during the termination grace.
    deadline = time.monotonic() + 2
    while time.monotonic() < deadline:
        tree.signal(signal.SIGTERM)
        p.poll()
        if not tree.sample():
            break
        time.sleep(0.1)
    for _ in range(10):
        tree.signal(signal.SIGKILL)
        p.poll()
        for pid in list(tree.sample()):
            if pid != p.pid:
                try:
                    os.waitpid(pid, os.WNOHANG)
                except ChildProcessError:
                    pass
        if not tree.sample():
            break
        time.sleep(0.1)
    p.wait(timeout=5)


def run_guarded(command, env, log, timeout):
    enable_subreaper()
    telemetry = log.with_suffix('.memory.jsonl')
    print('Memory samples:', telemetry, flush=True)
    # Flush and fsync telemetry every five seconds so an abrupt interruption
    # leaves evidence. Nix writes its own output directly to a separate file.
    with log.open('w') as output, telemetry.open('w') as samples:
        p = None
        tree = None
        old_handlers = {}
        started = time.monotonic()
        peak = 0
        last_sample = -5.0
        status = None
        reason = 'running'

        def interrupted(signum, _frame):
            raise SystemExit(128 + signum)

        def record(selected, free, event):
            data = {
                'time': time.strftime('%Y-%m-%dT%H:%M:%S%z'),
                'elapsed_s': round(time.monotonic() - started, 2),
                'event': event,
                'rss_mib': round(sum(x.rss for x in selected.values()) / MIB, 1),
                'peak_rss_mib': round(peak / MIB, 1),
                'available_mib': round(free / MIB, 1),
                'processes': [
                    {'pid': x.pid, 'ppid': x.ppid, 'pgid': x.pgid,
                     'start_ticks': x.started, 'rss_mib': round(x.rss / MIB, 1),
                     'threads': x.threads}
                    for x in selected.values()
                ],
            }
            samples.write(json.dumps(data) + '\n')
            samples.flush()
            os.fsync(samples.fileno())

        try:
            for sig in (signal.SIGTERM, signal.SIGHUP, signal.SIGINT):
                old_handlers[sig] = signal.signal(sig, interrupted)
            p = subprocess.Popen(command, env=env, start_new_session=True,
                                 preexec_fn=limits, stdout=output, stderr=subprocess.STDOUT)
            # Session and process-group IDs are known even if a very short
            # command exits before its first /proc sample.
            tree = ProcessTree(Process(p.pid, os.getpid(), p.pid, p.pid, -1, 0, 1))
            while True:
                selected = tree.sample()
                free = available()
                rss = sum(x.rss for x in selected.values())
                peak = max(peak, rss)
                elapsed = time.monotonic() - started
                status = p.poll()
                if elapsed - last_sample >= 5:
                    record(selected, free, 'sample')
                    last_sample = elapsed
                if status is not None:
                    reason = 'completed' if status == 0 else 'failed'
                    break
                if elapsed > timeout:
                    status, reason = 124, 'time limit reached'
                    break
                if rss > 1536 * MIB or free < 2048 * MIB:
                    status, reason = 75, 'memory safety threshold reached'
                    break
                time.sleep(0.25)
        except BaseException:
            reason = 'interrupted'
            raise
        finally:
            try:
                if p is not None and tree is not None:
                    try:
                        record(tree.sample(), available(), reason)
                    finally:
                        # Cleanup must still run if telemetry or /proc fails.
                        stop(p, tree)
            finally:
                for sig, handler in old_handlers.items():
                    signal.signal(sig, handler)
        print(f'Exit: {status}; sampled tree peak RSS: {peak / MIB:.0f} MiB; {reason}')
    return status if status >= 0 else 128 - status


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['plan', 'build', 'eval'], default='plan', nargs='?')
    parser.add_argument('--package', choices=['opencode-droid'], help='Test only this package')
    parser.add_argument('--timeout', type=int, default=1800,
                        help='Stop after this many seconds (default: 1800)')
    args = parser.parse_args()
    if args.timeout <= 0:
        parser.error('--timeout must be positive')
    if available() < 3072 * MIB:
        parser.error('Less than 3 GiB available RAM. Close other apps and retry.')
    flake = str(Path(__file__).resolve().parents[1])
    attr = f'packages.aarch64-linux.{args.package}' if args.package else DEFAULT_TARGET
    target = 'path:' + flake + '#' + attr
    result = CACHE / ('result-' + args.package if args.package else 'result')
    # Force the local store: a daemon's builders would escape this process tree.
    # No activation, profile replacement, flake updates or garbage collection.
    command = ['nix', 'eval' if args.action == 'eval' else 'build', '--store', 'local',
               '--impure', '--no-write-lock-file', '--max-jobs', '1', '--cores', '1',
               '--option', 'max-substitution-jobs', '1',
               '--option', 'http-connections', '1']
    if args.action == 'eval':
        command += ['--option', 'max-jobs', '0', '--raw', target + '.drvPath']
    else:
        command += ['--out-link', str(result), target]
        if args.action == 'plan':
            command += ['--dry-run', '--option', 'max-jobs', '0']
    env = os.environ.copy()
    env.update(GC_NPROCS='1', GC_INITIAL_HEAP_SIZE=str(64 * MIB),
               GC_MAX_HEAP_SIZE=str(768 * MIB), MALLOC_ARENA_MAX='2')
    CACHE.mkdir(parents=True, exist_ok=True)
    label = args.action + ('-' + args.package if args.package else '')
    log = CACHE / (time.strftime('%Y%m%d-%H%M%S-') + label + '.log')
    print('Log:', log, flush=True)
    status = run_guarded(command, env, log, args.timeout)
    with log.open('rb') as output:
        output.seek(max(0, log.stat().st_size - 6000))
        print(output.read().decode(errors='replace'))
    if status == 0:
        if args.action == 'plan':
            print('Plan succeeded. Nothing was activated. Run with "build" to build.')
        elif args.action == 'build':
            if args.package:
                print('Package built (not activated):', result)
            else:
                print('Build succeeded. To apply it, run:', result / 'activate')
    return status


if __name__ == '__main__':
    sys.exit(main())
