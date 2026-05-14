---
name: claude-forkchat
description: Fork the current Claude Code conversation into a sibling Apple Terminal tab (default) or window. Use when the user invokes /claude-forkchat, /claude-forkchat tab, /claude-forkchat window, or asks to "fork this chat", "branch this conversation into another tab/window", "open a fork alongside", "clone this session", "duplicate this session". Original session keeps running unchanged; the fork starts fresh with its own new session ID, seeded from the current transcript via `claude --resume <id> --fork-session`. Differs from the built-in `/branch` command, which switches the *current* terminal into the fork — /claude-forkchat keeps both alive side-by-side.
---

# /claude-forkchat

Forks the current Claude Code session and opens it alongside the original. The current session keeps running where it is; the new tab or window opens a forked copy with its own session ID, seeded from the current transcript.

Built-in `/branch` already exists, but it switches the active terminal into the fork. Use `/claude-forkchat` when you want both threads alive at once.

## Modes

- `/claude-forkchat` → same as `/claude-forkchat tab`
- `/claude-forkchat tab` → new tab in the current Terminal window (Cmd+T)
- `/claude-forkchat window` → brand-new Terminal window

Any other argument exits with an error.

## How to run

Pass the user's argument straight through to the helper (default `tab` if none):

```bash
~/.claude/skills/claude-forkchat/scripts/claude-forkchat.sh tab     # default
~/.claude/skills/claude-forkchat/scripts/claude-forkchat.sh window
```

Echo the script's stdout (`forked from <session-id> into new tab` or `... into new window`). On non-zero exit, surface stderr verbatim.

## First-time execution (Accessibility permission for `tab` mode)

`tab` mode sends Cmd+T to the front Terminal window via System Events, which macOS gates behind **Accessibility permission**. If the permission dialog doesn't appear automatically, `osascript` fails with `not allowed to send keystrokes. (1002)`.

Set it up once:

1. **System Settings → Privacy & Security → Accessibility**
2. Enable **Terminal** and **claude** (click + to add if missing — `which claude` shows the path).
3. Quit and relaunch Claude Code.

`window` mode uses `do script` with no keystrokes and needs no Accessibility permission.

## How it works

1. Finds the current session's transcript file via `lsof -p $PPID` (the Bash shell's parent is the running `claude` process).
2. Falls back to the most recently modified JSONL under `~/.claude/projects/<encoded-cwd>/` if `lsof` returns nothing.
3. Activates Terminal.app and either sends Cmd+T (`tab`) or calls `do script` with no `in` clause (`window`).
4. `cd`s to the original `cwd` and runs `claude --resume <session-id> --fork-session`.

If `tab` is requested but no Terminal window is open, the script falls back to `window` automatically.

## Caveats

- The fork is seeded from whatever has been **flushed to disk** at invocation time. The in-flight `/claude-forkchat` turn itself may not appear in the cloned session.
- Apple Terminal only. Other terminals (`iTerm.app`, `WarpTerminal`, `ghostty`) trigger a stderr warning and the script falls back to driving Terminal.app anyway.
- Apple Terminal's split panes (Cmd+D) aren't cleanly addressable via AppleScript, so `tab` creates a *tab*, not a literal split pane.
- Requires `lsof`, `osascript`, and `claude` on `$PATH`.
