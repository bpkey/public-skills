# Public Skills

A small, curated set of [Claude Code](https://claude.com/claude-code) global skills that fill gaps in the built-in commands. Each one is a thin shim around AppleScript / Apple Terminal — macOS only.

## What's here

- **`/clone`** — fills a gap. Closest to the built-in `/branch`, but `/branch` swaps the current terminal into the fork; `/clone` keeps the original session alive in this tab and opens the fork in a sibling tab (default) or window. Backed by `claude --resume <id> --fork-session`.
- **`/newTab`** — fills a gap. Nothing native opens a cold (non-resumed) Claude session in a new Terminal *tab* in the same window. Inherits the current working directory.
- **`/newWindow`** — fills a gap. Nothing native opens a cold (non-resumed) Claude session in a new Terminal *window*. Inherits the current working directory.

`/newTab` and `/newWindow` start fresh — no transcript carryover, but the new shell `cd`s to the same `cwd` you ran the command from, so `claude` boots into the same project context. `/clone` carries the current conversation forward (and also stays in `cwd`).

## Installing

Each top-level entry in this repo is a directory containing `SKILL.md` plus a helper script. To install one as a global skill, drop or symlink the directory under `~/.claude/skills/`:

```bash
ln -s "$PWD/clone"     ~/.claude/skills/clone
ln -s "$PWD/newTab"    ~/.claude/skills/newTab
ln -s "$PWD/newWindow" ~/.claude/skills/newWindow
```

The skill becomes available in the next Claude Code session — type `/clone`, `/newTab`, or `/newWindow`.

## Requirements

- macOS with **Apple Terminal** as the active terminal (`$TERM_PROGRAM=Apple_Terminal`). Other terminals aren't wired up yet — patches welcome.
- `claude` CLI on `$PATH`.
- Standard tools already on every Mac: `lsof`, `osascript`, `sed`, `awk`.
- For `/clone here` (the default) and `/newTab`: **macOS Accessibility permission** for `osascript` / Terminal, because the new-tab path sends Cmd+T via System Events. The first invocation may fail with `not allowed to send keystrokes (1002)` — grant permission in **System Settings → Privacy & Security → Accessibility**, then quit and relaunch Claude Code. `/clone new` and `/newWindow` don't need this permission.

## Source of truth

This repository **is** the canonical source for these three skills — `clone/`, `newTab/`, and `newWindow/` are real directories containing the actual `SKILL.md` and helper scripts. Edit them here.

The author's other (private) machine-config repo includes relative symlinks pointing back into this repo so the skills become available under `~/.claude/skills/<name>/` without copying any files. That is purely a consumer-side detail; if you've cloned this repo, you have everything you need.
