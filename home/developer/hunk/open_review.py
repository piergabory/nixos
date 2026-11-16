import argparse
import json
import os
from pathlib import Path
import shlex
import subprocess
import sys


def run(*args, **kwargs):
    return subprocess.run(
        args, check=True, capture_output=True, text=True, timeout=15, **kwargs
    ).stdout.strip()


def repository(path):
    return Path(run("git", "-C", str(path), "rev-parse", "--show-toplevel")).resolve()


def pane_repository(pane):
    cwd = pane.get("pane_cwd")
    if not cwd:
        return None
    try:
        return repository(cwd)
    except (OSError, subprocess.SubprocessError):
        return None


def command_name(pane):
    command = pane.get("terminal_command") or pane.get("pane_command") or ""
    try:
        words = shlex.split(command)
    except ValueError:
        return ""
    return Path(words[0]).name if words else ""


def select_panes(panes, repo, pane_id):
    live = [
        pane for pane in panes
        if not pane.get("is_plugin") and not pane.get("exited")
        and not pane.get("is_suppressed")
    ]
    candidates = [
        pane for pane in live
        if command_name(pane) == "opencode" and pane_repository(pane) == repo
    ]
    inherited = [pane for pane in candidates if str(pane["id"]) == pane_id]
    if len(inherited) == 1:
        origin = inherited[0]
    elif len(candidates) == 1:
        origin = candidates[0]
    else:
        raise ValueError("Cannot identify a unique OpenCode pane for this checkout.")

    reviews = [
        pane for pane in live
        if pane["tab_id"] == origin["tab_id"]
        and command_name(pane) == "hunk" and pane_repository(pane) == repo
    ]
    if len(reviews) > 1:
        raise ValueError("Several Hunk panes match this checkout and tab; ask which to use.")
    return origin, reviews[0] if reviews else None


def ensure_review(path, dry_run=False):
    session = os.environ.get("ZELLIJ_SESSION_NAME")
    if not session:
        raise ValueError("No Zellij session identity; ask the user to open Hunk manually.")
    repo = repository(path)
    action = ("zellij", "--session", session, "action")
    panes = json.loads(run(*action, "list-panes", "--all", "--json"))
    origin, review = select_panes(panes, repo, os.environ.get("ZELLIJ_PANE_ID"))
    command = [
        *action, "new-pane", "--tab-id", str(origin["tab_id"]),
        "--direction", "right", "--no-focus", "--cwd", str(repo),
        "--name", f"Hunk: {repo.name}", "--close-on-exit",
        "--", "hunk", "diff", "--watch", "--agent-notes",
    ]
    result = {
        "repository": str(repo), "session": session, "tab_id": origin["tab_id"],
        "opencode_pane": f"terminal_{origin['id']}",
        "status": "reused" if review else "would-open" if dry_run else "opened",
    }
    if review:
        result["hunk_pane"] = f"terminal_{review['id']}"
    elif dry_run:
        result["command"] = command
    else:
        result["hunk_pane"] = run(*command)
    return result


def main():
    parser = argparse.ArgumentParser(description="Reuse or open a Hunk review in OpenCode's Zellij tab.")
    parser.add_argument("--repo", default=".")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    try:
        print(json.dumps(ensure_review(args.repo, args.dry_run), indent=2))
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print(f"hunk-review-open: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
