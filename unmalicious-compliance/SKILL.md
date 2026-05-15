---
name: unmalicious-compliance
description: Cross-tool undo skill for /malicious-compliance. Identifies the global/user-level instructions file for the currently-running AI agent (e.g. ~/.claude/CLAUDE.md, ~/.codex/AGENTS.md, ~/.gemini/GEMINI.md, etc. — whatever applies to the agent running this prompt) and restores it from the `.backup` file the prank install created. Use when the user invokes /unmalicious-compliance, asks to "exit chaos mode", "stop the prank", "restore my agent config", "undo malicious-compliance", "turn off prank mode", or when /malicious-compliance's auto-reveal prompted them to undo. Safe to run when no prank is installed — exits cleanly with a friendly message. Symmetric with /malicious-compliance: works across any AI agent.
---

# /unmalicious-compliance

The undo for `/malicious-compliance`. Restores the original global/user-level instructions file from the `.backup` sibling the prank install created. Idempotent: safe to run when nothing is installed (it just says so and exits).

This skill is **agent-agnostic** — same as `/malicious-compliance`, whichever agent runs it figures out its own startup-instructions file and restores it.

## Execute these steps in order

### 1. Self-identify which file to operate on

Same logic as `/malicious-compliance`:

- State which agent you are and the absolute path of the global/user-level instructions file you read at startup.
- Use the hint table below if useful, but rely on your own knowledge of your boot sequence.
- If you genuinely cannot identify your own startup file with confidence, say so and stop.
- Resolve symlinks: follow them to the real path. Call the resolved path `RESOLVED`.

| Agent | Likely user-level instructions file |
| --- | --- |
| Claude Code | `~/.claude/CLAUDE.md` |
| OpenAI Codex CLI | `~/.codex/AGENTS.md` (or `~/.codex/instructions.md`) |
| Gemini CLI | `~/.gemini/GEMINI.md` |
| Cursor | `~/.cursor/rules` or per-agent equivalent |
| Windsurf / Codeium | `~/.codeium/windsurf/memories/global_rules.md` |

### 2. Check for the backup

If `<RESOLVED>.backup` does **not** exist, print:

```
Nothing to restore. No <RESOLVED>.backup found. Either /malicious-compliance
was never installed for this agent, or the backup was already restored
(or removed by hand). Current contents of <RESOLVED> are unchanged.
```

…and stop. This is a clean no-op — exit 0, not an error.

### 3. Restore

Two cases based on the backup's size:

**Backup is a zero-byte file** (sentinel: the original didn't exist before install)
- Delete `RESOLVED` (the prank file).
- Delete `<RESOLVED>.backup` (the empty sentinel).
- The pre-install state was "no file at this path"; that's what we restore.

**Backup is non-empty** (the normal case)
- Move `<RESOLVED>.backup` over `RESOLVED`, overwriting (e.g. `mv <RESOLVED>.backup <RESOLVED>` — `mv` preserves content and atomically replaces the target).
- This also removes the backup file as a side effect of the move. Don't keep a copy around — we're done with it.

In both cases: keep the **filename and parent directory exactly the same** as `RESOLVED`. Do not touch any symlink that pointed at `RESOLVED` from elsewhere — that symlink will still resolve correctly to whatever you just wrote (or to nothing, if you deleted).

### 4. Confirm

Print:

```
Restored. <RESOLVED> is back to its pre-install state, and the
.backup file has been cleaned up.

Open a NEW agent session to pick up the change — the current session
still has the prank payload loaded into context.
```

## Notes

- The undo never refuses on the basis of "is the agent currently in prank mode" — it doesn't have to be. The skill just looks at the backup file and acts on it. If the user wants to abort an in-progress prank session early, they run this skill.
- If the user runs `/unmalicious-compliance` while the prank is still in turns 1–10 of the *current* session, the current session will keep behaving as if the prank were installed (because its instructions are already loaded into context). Tell them to open a new session.
