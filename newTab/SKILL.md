---
name: newTab
description: Open a new tab in the current macOS Terminal window and start a fresh `claude` session in the same working directory. Use whenever the user invokes /newTab, or asks to "open a new terminal tab with claude", "start another claude session in a new tab", "spin up a fresh claude alongside this one", "open another claude in this window". Differs from /clone — /clone forks the *current* conversation (resumes its transcript), whereas /newTab starts a completely fresh session with no prior context. The current session keeps running unchanged.
---

# /newTab

Opens a new tab in the front Apple Terminal window and starts a fresh `claude` session in the same working directory. The current session keeps running where it is.

Use this when you want a second Claude session in parallel **without** carrying over the current conversation. If you instead want to fork the current transcript so both threads share history up to this point, use `/clone` instead.

## How to run

Run the helper script with no arguments:

```bash
~/.claude/skills/newTab/scripts/newTab.sh
```

Echo the script's stdout back to the user (`opened new tab with fresh claude in <cwd>` or, if no front Terminal window existed, `opened new window with fresh claude in <cwd>`). On non-zero exit, surface stderr verbatim — it explains what went wrong (missing Accessibility permission, etc.).

## First-time execution (Accessibility permission)

`/newTab` sends Cmd+T to the front Terminal window via AppleScript / System Events, which macOS gates behind **Accessibility permission**. The system permission dialog does not always appear automatically; when it doesn't, `osascript` fails with `not allowed to send keystrokes. (1002)` and the script exits non-zero.

If that happens, set it up once:

1. Open **System Settings → Privacy & Security → Accessibility**.
2. Enable **Terminal** and **claude**. If either is missing, click **+** to add it — `which claude` shows the CLI path. Some setups also require adding `/usr/bin/osascript` explicitly.
3. **Quit and relaunch Claude Code (and Terminal).** Accessibility state is captured at process launch; toggling the setting does not affect already-running processes.

This is the same setup used by `/clone here`. If you've already enabled it for `/clone`, `/newTab` works without further action.

## How it works

1. Activates Terminal.app and sends Cmd+T to the front window to spawn a new tab.
2. Runs `cd <current cwd> && claude` in that new tab via `do script ... in front window`.
3. If no front Terminal window exists, falls back to opening a new window with the same command (so the user always sees something happen, rather than a silent failure).

## Caveats

- Apple Terminal only. Other terminals (`iTerm.app`, `WarpTerminal`, `ghostty`) trigger a stderr warning and the script falls back to driving Terminal.app anyway.
- Tab, not split pane — Apple Terminal's split panes (Cmd+D) aren't cleanly addressable via AppleScript.
- Requires `osascript` and `claude` on `$PATH` (both present by default on the user's Macs).
