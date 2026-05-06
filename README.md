# Public Skills

A small, curated set of [Claude Code](https://claude.com/claude-code) global skills that fill gaps in the built-in commands. Each one is a thin shim around AppleScript / Apple Terminal — macOS only.

## What's here

- **`/clone`** — fills a gap. Closest to the built-in `/branch`, but `/branch` swaps the current terminal into the fork; `/clone` keeps the original session alive in this tab and opens the fork in a sibling tab (default) or window. Backed by `claude --resume <id> --fork-session`.
- **`/newTab`** — fills a gap. Nothing native opens a cold (non-resumed) Claude session in a new Terminal *tab* in the same window. Inherits the current working directory.
- **`/newWindow`** — fills a gap. Nothing native opens a cold (non-resumed) Claude session in a new Terminal *window*. Inherits the current working directory.

`/newTab` and `/newWindow` start fresh — no transcript carryover, but the new shell `cd`s to the same `cwd` you ran the command from, so `claude` boots into the same project context. `/clone` carries the current conversation forward (and also stays in `cwd`).

## Installing

Three install paths — pick whichever fits.

### 1. One-line curl (no clone)

Pulls only these three skill directories from the repo's tarball into `~/.claude/skills/`:

```bash
mkdir -p ~/.claude/skills && \
curl -fsSL https://github.com/bpkey/public-skills/archive/refs/heads/main.tar.gz | \
tar -xz -C ~/.claude/skills --strip-components=1 \
  public-skills-main/clone \
  public-skills-main/newTab \
  public-skills-main/newWindow
```

Re-run the same command later to update.

### 2. Ask Claude Code to install them

Paste this prompt into a Claude Code session:

> Install the `/clone`, `/newTab`, and `/newWindow` skills from `https://github.com/bpkey/public-skills` into `~/.claude/skills/`. Each is a directory containing a `SKILL.md` and a helper shell script. Don't clone the repo — fetch only those three directories from the `main` branch tarball, preserve the executable bit on the helper scripts, and confirm by listing the contents of `~/.claude/skills/clone/`, `~/.claude/skills/newTab/`, and `~/.claude/skills/newWindow/`.

### 3. Clone and symlink (if you want `git pull` updates)

Run this from wherever you keep your repos — the symlinks resolve via `$PWD` so the destination is up to you:

```bash
git clone https://github.com/bpkey/public-skills.git
cd public-skills
ln -s "$PWD/clone"     ~/.claude/skills/clone
ln -s "$PWD/newTab"    ~/.claude/skills/newTab
ln -s "$PWD/newWindow" ~/.claude/skills/newWindow
```

After installing by any method, the skills become available in your next Claude Code session — type `/clone`, `/newTab`, or `/newWindow`.

## Requirements

- macOS with **Apple Terminal** as the active terminal (`$TERM_PROGRAM=Apple_Terminal`). Other terminals aren't wired up yet — patches welcome.
- `claude` CLI on `$PATH`.
- Standard tools already on every Mac: `lsof`, `osascript`, `sed`, `awk`.
- For `/clone here` (the default) and `/newTab`: **macOS Accessibility permission** for `osascript` / Terminal, because the new-tab path sends Cmd+T via System Events. The first invocation may fail with `not allowed to send keystrokes (1002)` — grant permission in **System Settings → Privacy & Security → Accessibility**, then quit and relaunch Claude Code. `/clone new` and `/newWindow` don't need this permission.

