# Public Skills

A small, curated set of [Claude Code](https://claude.com/claude-code) global skills that fill gaps in the built-in commands. Each one is a thin shim around AppleScript / Apple Terminal — macOS only.

## What's here

- **`/clone`** — fills a gap. Closest to the built-in `/branch`, but `/branch` swaps the current terminal into the fork; `/clone` keeps the original session alive in this tab and opens the fork in a sibling tab (default) or window. Backed by `claude --resume <id> --fork-session`.
- **`/newTab`** — fills a gap. Nothing native opens a cold (non-resumed) Claude session in a new Terminal *tab* in the same window.
- **`/newWindow`** — fills a gap. Nothing native opens a cold (non-resumed) Claude session in a new Terminal *window*.

`/newTab` and `/newWindow` start fresh — no transcript carryover. `/clone` carries the current conversation forward.

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

The canonical files for these skills live in the author's private [`tools-config`](https://github.com/bpkey/tools-config) repo at `skills/<name>/`. The directory entries in *this* repo are **relative symlinks** pointing back to that path:

```
clone     -> ../tools-config/skills/clone
newTab    -> ../tools-config/skills/newTab
newWindow -> ../tools-config/skills/newWindow
```

The symlinks resolve on the author's machines because `tools-config` and `public-skills` sit side-by-side under `~/repo/`. **If you cloned this repo standalone, the symlinks will be broken** — you can either also clone `tools-config` next to it, or copy the resolved file contents from this repo's GitHub web view (GitHub renders symlinked directories as their resolved targets when both repos are accessible to the same user).

Edits should always be made in `tools-config/skills/<name>/`, not here.
