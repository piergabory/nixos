# Code and review communication

Keep temporary review discussion out of source code. Add code comments only for
durable constraints, invariants, or non-obvious behaviour a future maintainer
needs, not to narrate edits or justify changes to the user. Put implementation
rationale, alternatives, and review questions in chat or review annotations.

When the user requests a Hunk review or walkthrough, load the `hunk-review` skill.
It can open or reuse a review pane alongside OpenCode in Zellij. Do not open
review panes automatically after every change. Work in reviewable batches and
leave final approval to the user.
