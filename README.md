# Public Skills

A small, curated set of [Claude Code](https://claude.com/claude-code) global skills that fill gaps in the built-in commands. Each one is a thin shim around AppleScript / Apple Terminal — macOS only.

## What's here

- **`/clone`** — fills a gap. Closest to the built-in `/branch`, but `/branch` swaps the current terminal into the fork; `/clone` keeps the original session alive in this tab and opens the fork in a sibling tab (default) or window. Backed by `claude --resume <id> --fork-session`.
- **`/newTab`** — fills a gap. Nothing native opens a cold (non-resumed) Claude session in a new Terminal *tab* in the same window. Inherits the current working directory.
- **`/newWindow`** — fills a gap. Nothing native opens a cold (non-resumed) Claude session in a new Terminal *window*. Inherits the current working directory.

`/newTab` and `/newWindow` start fresh — no transcript carryover, but the new shell `cd`s to the same `cwd` you ran the command from, so `claude` boots into the same project context. `/clone` carries the current conversation forward (and also stays in `cwd`).

## Installing

**Recommended: option 1 (clone + symlink).** It's the only path that lets you `git pull` to pick up updates. Options 2 and 3 freeze a snapshot at install time — to update, you'd have to re-run the install command and remember to do so.

### 1. Clone and symlink — recommended

Run from wherever you keep your repos. The symlinks resolve via `$PWD`, so the clone destination is up to you:

```bash
git clone https://github.com/bpkey/public-skills.git
cd public-skills
ln -s "$PWD/clone"     ~/.claude/skills/clone
ln -s "$PWD/newTab"    ~/.claude/skills/newTab
ln -s "$PWD/newWindow" ~/.claude/skills/newWindow
```

To update later: `cd` back into the clone and `git pull` — the symlinks pick up changes automatically, no reinstall needed.

### 2. Let an AI tool install it for you (same as option 1, interactive)

Paste this prompt into Claude Code (or any AI coding tool with shell access):

> I want to install the `/clone`, `/newTab`, and `/newWindow` Claude Code skills from `https://github.com/bpkey/public-skills`. First, ask me where I'd like to clone the repo (suggest `~/repo` if I already use that, otherwise the current directory) and wait for my answer. Once I confirm the location, `git clone` it there, then create symlinks from each of the three skill directories into `~/.claude/skills/<name>/`. Confirm by listing the contents of `~/.claude/skills/clone/`, `~/.claude/skills/newTab/`, and `~/.claude/skills/newWindow/`, and remind me I can `cd` into the clone and `git pull` to update later.

### 3. Quick try — one-line curl (no clone, no updates)

Useful only for a quick taste — there's no update mechanism, so eventually switch to option 1.

```bash
mkdir -p ~/.claude/skills && \
curl -fsSL https://github.com/bpkey/public-skills/archive/refs/heads/main.tar.gz | \
tar -xz -C ~/.claude/skills --strip-components=1 \
  public-skills-main/clone \
  public-skills-main/newTab \
  public-skills-main/newWindow
```

Re-running the same command overwrites with the latest `main`, but you'll only do that if you remember to.

After installing by any method, the skills become available in your next Claude Code session — type `/clone`, `/newTab`, or `/newWindow`.

## Requirements

- macOS with **Apple Terminal** as the active terminal (`$TERM_PROGRAM=Apple_Terminal`). Other terminals aren't wired up yet — patches welcome.
- `claude` CLI on `$PATH`.
- Standard tools already on every Mac: `lsof`, `osascript`, `sed`, `awk`.
- For `/clone here` (the default) and `/newTab`: **macOS Accessibility permission** for `osascript` / Terminal, because the new-tab path sends Cmd+T via System Events. The first invocation may fail with `not allowed to send keystrokes (1002)` — grant permission in **System Settings → Privacy & Security → Accessibility**, then quit and relaunch Claude Code. `/clone new` and `/newWindow` don't need this permission.

