---
name: clone
description: Fork the current Claude Code conversation into a sibling Terminal tab (default) or a new Terminal window. Use when the user invokes /clone, /clone here, /clone new, or asks to "branch this conversation into another tab/window", "open a fork in a new tab", "clone this session", "duplicate this session". Original session keeps running unchanged; the fork starts fresh with its own new session ID, seeded from the current transcript via `claude --resume <id> --fork-session`. Differs from the built-in `/branch` command, which switches the *current* terminal into the fork — `/clone` keeps both alive side-by-side.
---

# /clone

Forks the current Claude Code session and opens it alongside the original. The original session keeps running where it is; the new tab/window opens a forked copy with its own session ID, seeded from the current transcript.

Built-in `/branch` already exists, but it switches the active terminal into the fork. Use `/clone` instead when you want both threads alive at the same time.

## Modes

The skill accepts an optional argument selecting where the fork lands:

- `/clone` → same as `/clone here` (default)
- `/clone here` → new tab in the *current* Terminal window (Cmd+T)
- `/clone new` → brand-new Terminal window

If the user provides any other argument, the script exits with an error explaining the valid options.

## First-time setup (Accessibility permission for `here` mode)

`/clone` defaults to `here`, which sends Cmd+T to the front Terminal window via AppleScript / System Events. macOS gates this behind **Accessibility permission**, and the system permission dialog **does not always appear automatically**. When it doesn't, `osascript` fails with `not allowed to send keystrokes. (1002)` and the script exits non-zero.

Set this up once:

1. Open **System Settings → Privacy & Security → Accessibility**.
2. Enable **Terminal** and **claude**. If either is missing from the list, click **+** to add it — `which claude` shows the CLI path. Some setups also require adding `/usr/bin/osascript` explicitly.
3. **Quit and relaunch Claude Code (and Terminal).** Accessibility state is captured at process launch; toggling the setting does not affect already-running processes.

To skip the setup entirely, use `/clone new` — it opens a new window via `do script` (no keystrokes) and needs no Accessibility permission.

## How to run

Pass the user's argument straight through to the helper script (or `here` if they didn't provide one):

```bash
~/repo/tools-config/skills/clone/clone.sh here   # default
~/repo/tools-config/skills/clone/clone.sh new
```

Then echo the script's stdout back to the user (it prints `forked from <session-id> into new tab` or `... into new window`). On non-zero exit, surface the stderr message verbatim — it explains what went wrong (unknown mode, no transcript found, etc.).

## How it works

1. Finds the current session's transcript file via `lsof -p $PPID` (the Bash shell's parent is the running `claude` process).
2. Falls back to the most recently modified JSONL under `~/.claude/projects/<encoded-cwd>/` if `lsof` returns nothing.
3. Activates Terminal.app and either:
   - sends Cmd+T via System Events to spawn a new tab in the front window (`here`), or
   - calls `do script` with no `in` clause to spawn a new window (`new`).
4. `cd`s to the original `cwd` and runs `claude --resume <session-id> --fork-session`.

If `here` is requested but no Terminal window is currently open, the script falls back to `new` automatically rather than failing silently.

## Caveats

- The fork is seeded from whatever has been **flushed to disk** at invocation time. The in-flight `/clone` turn itself may not appear in the cloned session — same caveat as `claude --resume` from any sibling shell.
- `here` mode requires macOS Accessibility permission (see "First-time setup" above). `new` mode does not.
- Apple Terminal's split-panes (Cmd+D) aren't cleanly addressable via AppleScript, so `here` creates a *tab*, not a literal split pane. If you want split panes, use `new` and arrange windows manually, or open a feature request to add tmux integration here.
- Only Apple Terminal is currently wired up. Other terminals (`iTerm.app`, `WarpTerminal`, `ghostty`) trigger a stderr warning and the script falls back to driving Terminal.app anyway.
- Requires `lsof`, `osascript`, and `claude` on `$PATH` — all present by default on the user's Macs.
