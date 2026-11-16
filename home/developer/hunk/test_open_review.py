import os
from pathlib import Path
import subprocess
import unittest
from unittest.mock import patch

import open_review


REPO = Path("/repos/example")


def pane(identifier, command="opencode", tab=3, cwd=str(REPO), **extra):
    return dict(id=identifier, pane_command=command, tab_id=tab, pane_cwd=cwd, **extra)


class SelectPanesTests(unittest.TestCase):
    def setUp(self):
        self.repo = patch.object(open_review, "repository", side_effect=lambda path: Path(path))
        self.repo.start()
        self.addCleanup(self.repo.stop)

    def test_terminal_zero_is_not_confused_with_plugin_zero(self):
        origin, review = open_review.select_panes(
            [pane(0, is_plugin=True), pane(0), pane(7, "lazygit")], REPO, "0"
        )
        self.assertEqual(origin["id"], 0)
        self.assertIsNone(review)

    def test_reuses_only_hunk_in_same_tab_and_checkout(self):
        origin, review = open_review.select_panes(
            [pane(0), pane(1, "hunk", tab=4), pane(2, "hunk", cwd="/other"),
             pane(3, "hunk", exited=True), pane(4, "/nix/store/package/bin/hunk")],
            REPO, "0",
        )
        self.assertEqual(origin["tab_id"], 3)
        self.assertEqual(review["id"], 4)

    def test_falls_back_to_unique_checkout_if_environment_is_stale(self):
        origin, _ = open_review.select_panes(
            [pane(0, cwd="/other"), pane(2)], REPO, "0"
        )
        self.assertEqual(origin["id"], 2)

    def test_refuses_ambiguous_origin(self):
        with self.assertRaisesRegex(ValueError, "unique OpenCode"):
            open_review.select_panes([pane(1), pane(2, tab=4)], REPO, None)

    def test_refuses_missing_origin(self):
        with self.assertRaises(ValueError):
            open_review.select_panes([pane(0, "lazygit")], REPO, "0")

    def test_refuses_ambiguous_review(self):
        with self.assertRaisesRegex(ValueError, "Several Hunk"):
            open_review.select_panes([pane(0), pane(1, "hunk"), pane(2, "hunk")], REPO, "0")

    def test_unavailable_pane_cwd_is_ignored(self):
        self.repo.stop()
        with patch.object(open_review, "repository", side_effect=subprocess.CalledProcessError(1, "git")):
            self.assertIsNone(open_review.pane_repository(pane(0)))


class LauncherTests(unittest.TestCase):
    def setUp(self):
        environment = patch.dict(os.environ, {"ZELLIJ_SESSION_NAME": "test", "ZELLIJ_PANE_ID": "0"})
        environment.start()
        self.addCleanup(environment.stop)
        repo = patch.object(open_review, "repository", return_value=REPO)
        repo.start()
        self.addCleanup(repo.stop)

    @patch.object(open_review, "run", side_effect=['[{"id": 0}]', "terminal_9"])
    @patch.object(open_review, "select_panes", return_value=(pane(0), None))
    def test_opens_explicit_tab_without_focus_or_replacing_panes(self, select, run):
        result = open_review.ensure_review(REPO)
        command = run.call_args.args
        self.assertEqual(result["hunk_pane"], "terminal_9")
        self.assertEqual(command[:4], ("zellij", "--session", "test", "action"))
        self.assertEqual(command[command.index("--tab-id") + 1], "3")
        self.assertIn("--no-focus", command)
        self.assertNotIn("--in-place", command)
        self.assertEqual(command[-5:], ("--", "hunk", "diff", "--watch", "--agent-notes"))

    @patch.object(open_review, "run", return_value='[{"id": 0}]')
    @patch.object(open_review, "select_panes", return_value=(pane(0), pane(9, "hunk")))
    def test_existing_review_does_not_open_or_reload(self, select, run):
        self.assertEqual(open_review.ensure_review(REPO)["status"], "reused")
        self.assertEqual(run.call_count, 1)

    @patch.object(open_review, "run", return_value='[{"id": 0}]')
    @patch.object(open_review, "select_panes", return_value=(pane(0), None))
    def test_dry_run_does_not_open(self, select, run):
        self.assertEqual(open_review.ensure_review(REPO, dry_run=True)["status"], "would-open")
        self.assertEqual(run.call_count, 1)

    @patch.dict(os.environ, {}, clear=True)
    @patch.object(open_review, "run")
    def test_outside_zellij_does_not_run_commands(self, run):
        with self.assertRaisesRegex(ValueError, "No Zellij"):
            open_review.ensure_review(REPO)
        run.assert_not_called()


if __name__ == "__main__":
    unittest.main()
