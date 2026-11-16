---
name: hunk-review
description: Review changes with the user in Hunk, explain decisions beside the diff, and read or reply to inline feedback. Reuse or open a Hunk pane in the same Zellij tab as OpenCode when a review is requested.
---

# Hunk review

Use Hunk for review conversations, not source comments.

## Open or reuse the review

When the user requests a Hunk review or walkthrough, run:

```sh
hunk-review-open --repo /absolute/path/to/current/checkout
```

The launcher finds the OpenCode pane for this checkout, then reuses a matching
Hunk pane in its tab or opens `hunk diff --watch --agent-notes` without taking
keyboard focus. It does not replace existing panes. `--dry-run` inspects the
target without opening anything.

If the launcher cannot safely identify the OpenCode pane or Zellij session, ask
the user to identify it or open Hunk themselves. Do not guess, switch tabs,
type into existing panes, or close panes to make room. Outside Zellij, ask the
user to run `hunk diff --watch --agent-notes` in the checkout.

## Review together

Read `references/upstream.md` for the installed Hunk version's session commands
and follow that workflow after opening the pane. The local rules in this skill
take precedence over the upstream reference for pane creation, comparison
changes, and preserving human notes. If session registration is not
ready yet, retry `hunk session list --json`. Never launch an interactive Hunk TUI
directly through the shell tool; only the Zellij launcher should start one.

- Confirm the session belongs to the intended checkout. If several sessions
  match, use an explicit session ID; ask if their identity is ambiguous.
- Do not reload an existing review to a different comparison without asking.
- Explain only non-obvious decisions, risks, and alternatives beside the diff.
- Read human feedback with `hunk session comment list --repo <checkout> --type user --json`.
- When asked to address feedback, make the changes and reply using `--reply-to`.
  Explain any disagreement rather than silently ignoring a comment.
- Do not delete human notes or treat your response as the user's approval.
- Comments do not automatically wake the agent. Tell the user to send a message
  here when their review notes are ready.
