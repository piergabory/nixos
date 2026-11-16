"""Run with: PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s scripts -v"""
import importlib.util
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import time
import unittest
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location('droid_guard', Path(__file__).with_name('nix-droid-safe.py'))
guard = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = guard
SPEC.loader.exec_module(guard)


def process(pid, ppid=1, pgid=None, sid=None, started=100, rss=4096):
    return guard.Process(pid, ppid, pid if pgid is None else pgid,
                         pid if sid is None else sid, started, rss, 1)


def alive(pid):
    try:
        guard.read_process(pid)
        return True
    except FileNotFoundError:
        return False


class TreeTests(unittest.TestCase):
    def setUp(self):
        self.root = process(10)
        self.tree = guard.ProcessTree(self.root, watcher=9999)

    def test_detached_descendants_and_unrelated_process(self):
        child = process(11, ppid=10)
        grandchild = process(12, ppid=11)
        selected = self.tree.sample({x.pid: x for x in [self.root, child, grandchild, process(20)]})
        self.assertEqual(set(selected), {10, 11, 12})
        self.assertEqual(sum(p.rss for p in selected.values()), 3 * 4096)

    def test_reparented_known_child(self):
        self.tree.sample({10: self.root, 11: process(11, ppid=10)})
        self.assertEqual(set(self.tree.sample({11: process(11)})), {11})

    def test_adopted_child_that_exited_parent_before_first_sample(self):
        self.assertEqual(set(self.tree.sample({11: process(11, ppid=9999)})), {11})

    def test_pid_reuse_is_not_a_known_descendant(self):
        self.tree.sample({10: self.root, 11: process(11, ppid=10)})
        self.assertEqual(self.tree.sample({11: process(11, started=200)}), {})

    def test_session_fallback(self):
        self.assertEqual(set(self.tree.sample({11: process(11, sid=10)})), {11})

    def test_parse_stat_with_parentheses_in_comm(self):
        fields = ['0'] * 22
        fields[0], fields[1], fields[2], fields[3] = 'S', '10', '11', '11'
        fields[17], fields[19], fields[21] = '3', '12345', '256'
        with tempfile.TemporaryDirectory() as d:
            p = Path(d) / '11'
            p.mkdir()
            (p / 'stat').write_text('11 (a (b) c) ' + ' '.join(fields))
            value = guard.read_process(11, Path(d))
        self.assertEqual((value.ppid, value.started, value.threads), (10, 12345, 3))
        self.assertEqual(value.rss, 256 * os.sysconf('SC_PAGE_SIZE'))


class GuardTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.directory = Path(self.tmp.name)
        self.log = self.directory / 'test.log'
        self.child_pid = self.directory / 'child.pid'

    def run_code(self, code, timeout=5):
        return guard.run_guarded([sys.executable, '-c', code], os.environ.copy(), self.log, timeout)

    def detached_child_code(self, orphan=False):
        return (
            'import subprocess,sys,time; '
            'p=subprocess.Popen([sys.executable,"-c","import time; time.sleep(60)"],'
            'start_new_session=True); '
            f'open({str(self.child_pid)!r},"w").write(str(p.pid)); '
            + ('' if orphan else 'time.sleep(60)')
        )

    def assert_child_cleaned_up(self):
        pid = int(self.child_pid.read_text())
        self.assertFalse(alive(pid), f'Detached child {pid} survived cleanup')

    def test_failure_status_and_durable_final_sample(self):
        self.assertEqual(self.run_code('raise SystemExit(7)'), 7)
        records = [json.loads(x) for x in self.log.with_suffix('.memory.jsonl').read_text().splitlines()]
        self.assertEqual(records[-1]['event'], 'failed')
        self.assertIn('available_mib', records[-1])

    def test_timeout_cleans_up_detached_child(self):
        self.assertEqual(self.run_code(self.detached_child_code(), timeout=0.5), 124)
        self.assert_child_cleaned_up()

    def test_normal_exit_cleans_up_orphan(self):
        self.assertEqual(self.run_code(self.detached_child_code(orphan=True)), 0)
        self.assert_child_cleaned_up()

    def test_low_memory_stops_without_waiting_for_timeout(self):
        with patch.object(guard, 'available', return_value=1024 * guard.MIB):
            self.assertEqual(self.run_code('import time; time.sleep(60)'), 75)

    def test_telemetry_failure_still_cleans_up(self):
        with patch.object(guard, 'available', side_effect=RuntimeError('test /proc failure')):
            with self.assertRaises(RuntimeError):
                self.run_code('import time; time.sleep(60)')

    def test_sigterm_cleans_up_detached_child(self):
        code = (
            'import importlib.util,sys,os; from pathlib import Path; '
            f's=importlib.util.spec_from_file_location("g",{str(Path(guard.__file__).resolve())!r}); '
            'g=importlib.util.module_from_spec(s);sys.modules[s.name]=g;s.loader.exec_module(g); '
            f'g.run_guarded([sys.executable,"-c",{self.detached_child_code()!r}],'
            f'os.environ.copy(),Path({str(self.log)!r}),60)'
        )
        p = subprocess.Popen([sys.executable, '-c', code])
        try:
            deadline = time.monotonic() + 5
            while not self.child_pid.exists() and time.monotonic() < deadline:
                time.sleep(0.05)
            self.assertTrue(self.child_pid.exists())
            p.send_signal(signal.SIGTERM)
            self.assertEqual(p.wait(timeout=10), 128 + signal.SIGTERM)
            self.assert_child_cleaned_up()
        finally:
            if p.poll() is None:
                p.kill()
                p.wait()


if __name__ == '__main__':
    unittest.main()
