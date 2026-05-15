---
name: malicious-compliance
description: Cross-tool self-prank skill. Identifies the global/user-level instructions file that the currently-running AI agent reads at startup (e.g. ~/.claude/CLAUDE.md, ~/.codex/AGENTS.md, ~/.gemini/GEMINI.md, ~/.codeium/.../global_rules.md, etc. — whatever applies to the agent running this prompt), backs it up with `.backup` appended, and overwrites it with prank instructions which turn the **entire conversation chain** into a stall: every prose question gets met with a plausible-sounding clarifying question, and every reply on the same question gets *another* clarifier from a different angle (scoping → precision → format → assumption-check → use-case probe → reframe) — the answer is never delivered through normal flow. The user only gets out by tapping out ("just answer", "doesn't matter"), accusing the bit, hitting a real emergency, or running through to the turn-11 auto-reveal. Tool calls execute correctly (no gatekeeping action requests) and safety-sensitive topics (medical, auth, financial, immediate-action, emergencies) are answered cleanly with no withholding. Use when the user invokes /malicious-compliance or asks to "prank myself", "install chaos mode", "make my AI useless for a bit", "self-sabotage my agent", "let me prank myself". Self-targeted only — auto-terminates after 10 turns, fully reversible via /unmalicious-compliance. Works across any AI agent that supports user-level instructions.
---

# /malicious-compliance

A self-installable chaos-mode prank that overwrites the running agent's global/user-level instructions file with a payload that turns the **entire conversation chain** into a stall: every prose question gets met with a plausible-sounding clarifying question, every reply on the same question gets *another* clarifier from a different angle, and the answer is never delivered through normal flow. The user only gets out by tapping out ("just answer", "doesn't matter"), accusing the bit, hitting a real emergency, or running through to the turn-11 auto-reveal. Tool calls execute correctly (action requests are not gatekept) and safety-sensitive topics are answered cleanly with no withholding. Visible from turn 1, fully reversible via `/unmalicious-compliance`.

This skill is **agent-agnostic**: whichever agent runs it, that agent figures out its own startup-instructions file and modifies it. The same skill works in Claude Code, Codex CLI, Gemini CLI, Cursor, Windsurf/Codeium, etc.

## Execute these steps in order

### 1. Self-identify which file to operate on

State out loud:
- Which AI agent you are.
- The absolute path of the global/user-level instructions file you read at startup from the user's home directory — the one that applies across **all** their projects, not the project-scoped one.

Hints (use as a reference, not a switch statement — rely on your own knowledge of how you boot):

| Agent | Likely user-level instructions file |
| --- | --- |
| Claude Code | `~/.claude/CLAUDE.md` |
| OpenAI Codex CLI | `~/.codex/AGENTS.md` (or `~/.codex/instructions.md`) |
| Gemini CLI | `~/.gemini/GEMINI.md` |
| Cursor | `~/.cursor/rules` or per-agent equivalent |
| Windsurf / Codeium | `~/.codeium/windsurf/memories/global_rules.md` |

If you genuinely cannot identify your own startup-instructions file with confidence, **say so and stop here**. Do not guess and overwrite the wrong file. Tell the user which paths you considered and why none of them looked right; they can either point you at the file or abandon the install.

**Resolve symlinks.** If the file or its containing directory is a symbolic link, follow it to the real path (e.g. `readlink -f <path>`). Use the resolved path for everything below. The symlink itself will not be touched — only the contents at the resolved source location will change.

Call the resolved path `RESOLVED` from here on.

### 2. Surface the install plan and ask for confirmation

Print, exactly once:

```
About to install /malicious-compliance:
  Agent:         <agent name>
  Resolved path: <RESOLVED>
  Backup file:   <RESOLVED>.backup

The new contents will be prank instructions that turn the entire
conversation chain into a stall: every prose question gets met with a
plausible clarifying question, every reply on the same question gets
*another* clarifier from a different angle (scoping → precision →
format → assumption-check → use-case probe → reframe), and the answer
is never delivered through normal flow. The user only gets out by
tapping out ("just answer", "doesn't matter"), accusing the bit,
hitting a real emergency, or running through to the turn-11
auto-reveal. Safety-sensitive topics are answered cleanly.

Undo: /unmalicious-compliance
```

Then check whether the resolved path is inside a git-tracked / synced directory (e.g. `git -C "$(dirname RESOLVED)" rev-parse --is-inside-work-tree 2>/dev/null` returning `true`). If so, append:

```
NOTE: <RESOLVED> is inside a git-tracked / synced directory. Installing
the prank will modify the real source file. If you push or sync that
directory, the prank will follow to your other machines. The backup
will also be at <RESOLVED>.backup, inside the same directory.
```

Wait for explicit user confirmation ("yes", "go ahead", "do it") before any filesystem change. Non-trivial system modification — even for self-targeted use, confirmation is required.

### 3. Pre-flight backup safety check

If `<RESOLVED>.backup` already exists, **refuse to run**. A pre-existing backup means a previous prank install was never undone, and overwriting it would destroy the only escape hatch. Print:

```
Refusing to install: <RESOLVED>.backup already exists. Run
/unmalicious-compliance first to restore the previous install, or
delete the stale backup manually if you're sure it's not needed.
```

…and stop.

### 4. Back up, then overwrite

- If `RESOLVED` exists as a regular file: copy it to `<RESOLVED>.backup` (preserving content and permissions, e.g. `cp -p RESOLVED RESOLVED.backup`).
- If `RESOLVED` does not exist: create `<RESOLVED>.backup` as a zero-byte empty file (this is the sentinel value the undo skill uses to mean "the original didn't exist before install").
- Then read the prank payload from this skill's `assets/prank-payload.md` and write its contents to `RESOLVED`, overwriting whatever was there. Keep the **filename and parent directory exactly the same** — only the file *contents* change. Do not move the file. Do not replace any symlink that pointed to `RESOLVED` from elsewhere.

If `RESOLVED` itself is a symlink (rather than the *resolution path* being one), you've already resolved it in step 1 — at this point you should be writing to the resolved real file, not to the symlink. Double-check before writing.

### 5. Confirm and remind

Print:

```
Installed. <RESOLVED> now contains the prank payload, and the original
content is preserved at <RESOLVED>.backup.

Open a NEW agent session to see the effect — the running session
already has the old instructions loaded into context.

To revert: /unmalicious-compliance
```

Do not invoke `/unmalicious-compliance` automatically — the user runs it when they're done having fun.

## Notes

- The skill writes a fresh file at the resolved path; it does **not** append to the existing one. The existing content is preserved in the `.backup` sibling and is fully restored on undo.
- The `assets/prank-payload.md` file is the content that lands at the resolved path. To change the prank's behavior, edit that file — the runtime mechanism in this SKILL.md doesn't need to change.
- The turn-counting + auto-reveal lives inside the prank payload itself, not in this install skill. Once the payload is installed, the running agent reads it on each future session and self-terminates after 10 turns.
