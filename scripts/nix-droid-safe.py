#!/usr/bin/env python3
"""Guard local Nix-on-Droid evaluation/builds; never activate or run GC.

Usage: python3 scripts/nix-droid-safe.py [plan|build|eval]
Logs and the build result live in ~/.cache/nix-droid-safe/.
Requires Linux /proc, Python 3 and Nix. Limits assume a local (not daemon) store.
"""
import argparse
import os
from pathlib import Path
import resource
import signal
import subprocess
import sys
import time

MIB = 1024 * 1024
CACHE = Path.home() / ".cache/nix-droid-safe"


def available():
    for line in Path('/proc/meminfo').read_text().splitlines():
        if line.startswith('MemAvailable:'):
            return int(line.split()[1]) * 1024
    raise RuntimeError('Cannot read MemAvailable; refusing unguarded build')


def group_rss(pgid):
    total = 0
    for entry in Path('/proc').iterdir():
        if not entry.name.isdigit():
            continue
        try:
            # comm can contain spaces and parentheses. Fields start at state.
            fields = (entry / 'stat').read_text().rsplit(')', 1)[1].split()
            if int(fields[2]) == pgid:
                total += int(fields[21]) * os.sysconf('SC_PAGE_SIZE')
        except (OSError, ValueError, IndexError):
            continue  # process exited or belongs to another Android app
    return total


def limits():
    # Inherited by builders, not by Pi or the invoking shell. AS includes
    # mappings and thread stacks: it is deliberately larger than the RSS cap.
    resource.setrlimit(resource.RLIMIT_AS, (2048 * MIB, 2048 * MIB))
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    os.nice(10)


def stop(p):
    try:
        os.killpg(p.pid, signal.SIGTERM)
        time.sleep(2)
        os.killpg(p.pid, signal.SIGKILL)
    except ProcessLookupError:
        pass
    p.wait()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['plan', 'build', 'eval'], default='plan', nargs='?')
    parser.add_argument('--timeout', type=int, default=1800, help='Stop after this many seconds (default: 1800)')
    args = parser.parse_args()
    if args.timeout <= 0:
        parser.error('--timeout must be positive')
    if available() < 2048 * MIB:
        parser.error('Less than 2 GiB available RAM. Close other apps and retry.')
    # No activation, profile replacement, flake updates or garbage collection.
    flake = str(Path(__file__).resolve().parents[1])
    # Snapshot the local working tree, including files not yet git-added.
    target = 'path:' + flake + '#nixOnDroidConfigurations.default.activationPackage'
    command = ['nix', 'eval' if args.action == 'eval' else 'build',
               '--impure', '--no-write-lock-file', '--max-jobs', '1', '--cores', '1',
               '--option', 'max-substitution-jobs', '1',
               '--option', 'http-connections', '1']
    if args.action == 'eval':
        # Do not compile missing import-from-derivation dependencies.
        command += ['--option', 'max-jobs', '0', '--raw', target + '.drvPath']
    else:
        command += ['--out-link', str(CACHE / 'result'), target]
        if args.action == 'plan':
            command += ['--dry-run', '--option', 'max-jobs', '0']
    env = os.environ.copy()
    env.update(GC_NPROCS='1', GC_INITIAL_HEAP_SIZE=str(64 * MIB),
               GC_MAX_HEAP_SIZE=str(768 * MIB), MALLOC_ARENA_MAX='2')
    CACHE.mkdir(parents=True, exist_ok=True)
    log = CACHE / (time.strftime('%Y%m%d-%H%M%S-') + args.action + '.log')
    print('Log:', log, flush=True)
    # Write directly to disk, avoiding pipe backpressure and retaining evidence
    # even if Android terminates the terminal app. Monitor in another terminal
    # with `tail -f <log>` if desired.
    with log.open('w') as output:
        p = subprocess.Popen(command, env=env, start_new_session=True,
                             preexec_fn=limits, stdout=output, stderr=subprocess.STDOUT)
        peak = 0
        started = time.monotonic()
        # Let the finally block stop the separate Nix process group even when
        # an outer runner sends SIGTERM or the terminal closes.
        def interrupted(signum, _frame):
            raise SystemExit(128 + signum)
        for sig in (signal.SIGTERM, signal.SIGHUP):
            signal.signal(sig, interrupted)
        try:
            while p.poll() is None:
                if time.monotonic() - started > args.timeout:
                    print('Stopping Nix: time limit reached; rerun to continue.', flush=True)
                    stop(p)
                    return 124
                rss = group_rss(p.pid)
                peak = max(peak, rss)
                if rss > 1536 * MIB or available() < 1024 * MIB:
                    print('Stopping Nix: memory safety threshold reached.', flush=True)
                    stop(p)
                    return 75
                time.sleep(0.25)
        finally:
            if p.poll() is None:
                stop(p)
    print(f'Exit: {p.returncode}; sampled process-group peak RSS: {peak / MIB:.0f} MiB')
    print(log.read_text()[-6000:])
    if p.returncode == 0:
        if args.action == 'plan':
            print('Plan succeeded. Nothing was activated. Run with "build" to build.')
        elif args.action == 'build':
            print('Build succeeded. To apply it, run:', CACHE / 'result/activate')
    return p.returncode if p.returncode >= 0 else 128 - p.returncode


if __name__ == '__main__':
    sys.exit(main())
