import contextlib
import io
import json
import plistlib
import subprocess
import unittest
from unittest.mock import patch

import preferences


class PreferencesTests(unittest.TestCase):
    def test_terminal_archives(self):
        font = plistlib.loads(preferences.encode({
            "archiveFont": {"name": "IoskeleyMonoNFM", "size": 14},
        }))
        self.assertEqual(font["$objects"][2], "IoskeleyMonoNFM")
        self.assertEqual(font["$objects"][1]["NSSize"], 14.0)
        color = plistlib.loads(preferences.encode({"archiveColor": "1d2021"}))
        self.assertEqual(color["$objects"][2]["NSID"], 7)

    def test_color_encoding(self):
        white = preferences.oklch("ffffff")["wrapped"]["oklch"]
        self.assertAlmostEqual(white["lightness"]["kind"]["exact"]["_0"], 1)
        self.assertAlmostEqual(white["chroma"]["kind"]["exact"]["_0"], 0)

    def test_activation_preserves_unmanaged_settings(self):
        existing_recipe = {"id": "other", "name": "My theme"}
        current = {
            "Window Settings": {"Other profile": {"name": "Other profile"}},
            "DVTWorkspaceSavedRecipes": json.dumps([existing_recipe, {"id": "managed"}]).encode(),
            "DVTWorkspaceThemeSettings": json.dumps({"light": {"default": {}}}).encode(),
        }
        settings = {
            "domain": "test.domain",
            "process": "Test",
            "merge": {"Window Settings": {"Stylix": {"name": "Stylix"}}},
            "mergeJSON": {"DVTWorkspaceThemeSettings": {"dark": {"savedRecipe": {"_0": "managed"}}}},
            "upsertJSON": {"DVTWorkspaceSavedRecipes": {"id": "managed", "name": "Stylix"}},
        }
        written = {}

        def run(command, **kwargs):
            if command[0] == "/usr/bin/pgrep":
                return subprocess.CompletedProcess(command, 1)
            if command[1] == "export":
                return subprocess.CompletedProcess(command, 0, stdout=plistlib.dumps(current))
            self.assertEqual(command[1], "import")
            written.update(plistlib.loads(kwargs["input"]))
            return subprocess.CompletedProcess(command, 0)

        with patch("preferences.subprocess.run", side_effect=run), contextlib.redirect_stdout(io.StringIO()):
            preferences.apply(settings, dry_run=False)
        self.assertIn("Other profile", written["Window Settings"])
        self.assertIn("Stylix", written["Window Settings"])
        self.assertIn("light", json.loads(written["DVTWorkspaceThemeSettings"]))
        self.assertEqual(json.loads(written["DVTWorkspaceSavedRecipes"]), [
            existing_recipe, {"id": "managed", "name": "Stylix"},
        ])

        written.clear()
        with patch("preferences.subprocess.run", side_effect=run), contextlib.redirect_stdout(io.StringIO()):
            preferences.apply(settings, dry_run=True)
        self.assertEqual(written, {})

    def test_running_app_is_skipped(self):
        with patch("preferences.subprocess.run", return_value=subprocess.CompletedProcess([], 0)) as run:
            with contextlib.redirect_stdout(io.StringIO()):
                preferences.apply({"domain": "test.domain", "process": "Test"}, dry_run=False)
            self.assertEqual(run.call_count, 1)


if __name__ == "__main__":
    unittest.main()
