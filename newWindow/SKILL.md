---
name: newWindow
description: Open a new macOS Terminal window and start a fresh `claude` session in the same working directory. Use whenever the user invokes /newWindow, or asks to "open a new terminal window with claude", "start another claude session in a separate window", "spin up a fresh claude in its own window", "open another claude window". Differs from /newTab — /newTab opens a new tab in the current Terminal window, whereas /newWindow opens a separate window. Differs from /clone — /clone forks the *current* conversation (resumes its transcript), whereas /newWindow starts a completely fresh session with no prior context. The current session keeps running unchanged.
---

# /newWindow

Opens a new Apple Terminal window and starts a fresh `claude` session in the same working directory. The current session keeps running where it is.

Use this when you want a second Claude session in a separate window **without** carrying over the current conversation. Related commands:

- `/newTab` — same idea but opens a new tab in the current Terminal window instead of a separate window.
- `/clone` — forks the *current* transcript so both threads share history up to this point.

## How to run

Run the helper script with no arguments:

```bash
~/repo/tools-config/skills/newWindow/newWindow.sh
```

Echo the script's stdout back to the user (`opened new window with fresh claude in <cwd>`). On non-zero exit, surface stderr verbatim.

## How it works

1. Activates Terminal.app.
2. Runs `cd <current cwd> && claude` via `do script "..."` — with no `in window` clause, AppleScript always opens a brand-new window.

No keystroke simulation is needed (unlike `/newTab`, which sends Cmd+T), so this skill does **not** require macOS Accessibility permission.

## Caveats

- Apple Terminal only. Other terminals (`iTerm.app`, `WarpTerminal`, `ghostty`) trigger a stderr warning and the script falls back to driving Terminal.app anyway.
- Requires `osascript` and `claude` on `$PATH` (both present by default on the user's Macs).
