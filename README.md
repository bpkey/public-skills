# Skills

A small collection of [Claude Code](https://claude.com/claude-code) helpers we use ourselves to work more efficiently with Claude — shared in case they help you too. Each one installs as a global skill and runs from a slash command in any Claude Code session. macOS only for now (thin shims around AppleScript / Apple Terminal).

## What's here

- **`/cloneClaudeConversation`** — fills a gap. Closest to the built-in `/branch`, but `/branch` swaps the current terminal into the fork; `/cloneClaudeConversation` keeps the original session alive in this tab and opens the fork **alongside** it — in a sibling tab by default (`/cloneClaudeConversation` or `/cloneClaudeConversation here`), or in a new window with `/cloneClaudeConversation new`. Backed by `claude --resume <id> --fork-session`.
- **`/newClaudeTab`** — fills a gap. Opens a fresh (non-resumed) Claude session in a new Terminal *tab*, in the **same working directory** as the running Claude — so the new session boots straight into your current project, no manual `cd` needed. (Cmd+T natively lands in `~`.)
- **`/newClaudeWindow`** — same as `/newClaudeTab` but a new Terminal *window* instead of a tab.

`/newClaudeTab` and `/newClaudeWindow` start fresh — no transcript carryover, but the new shell `cd`s to the same `cwd` you ran the command from, so `claude` boots into the same project context. `/cloneClaudeConversation` carries the current conversation forward (and also stays in `cwd`).

## Installing

The recommended way is the [`skills`](https://github.com/vercel-labs/skills) CLI by Vercel Labs — a general-purpose installer for AI-agent skills. It auto-detects which AI client(s) you have installed (Claude Code, Cursor, Codex, Windsurf, …) and drops the skills into each one's well-known directory.

### Recommended: `npx skills`

**Install all skills:**

```bash
npx skills add bpkey/skills -y -g
```

**Install just one skill** — replace `<skill-name>` with the directory name in the repo (e.g. `cloneClaudeConversation`, `newClaudeTab`, `newClaudeWindow`):

```bash
npx skills add bpkey/skills -s <skill-name> -y -g
```

What the flags mean:

- `-g` — install globally (into `~/.claude/skills/` for Claude Code, and the equivalent for any other detected client), as opposed to a single project.
- `-y` — skip interactive prompts; use sensible defaults.
- `-s <name>` — restrict to a single skill from the repo.

Update later with `npx skills update`. Remove with `npx skills remove`. List with `npx skills list`.

Full docs and flag reference: <https://github.com/vercel-labs/skills>.

### Alternative: manual clone + symlink

Useful if you want a local clone you can `git pull` directly or hack on. Run from wherever you keep your repos — the symlinks resolve via `$PWD`, so the clone destination is up to you.

**Install all skills:**

```bash
git clone https://github.com/bpkey/skills.git
cd skills
for d in */; do
  [ -f "$d/SKILL.md" ] && ln -s "$PWD/${d%/}" ~/.claude/skills/${d%/}
done
```

**Install just one skill:**

```bash
git clone https://github.com/bpkey/skills.git
cd skills
ln -s "$PWD/<skill-name>" ~/.claude/skills/<skill-name>
```

To update later, `cd` back into the clone and `git pull` — the symlinks pick up changes automatically, no reinstall needed.

After installing by either method, the skills become available in your next Claude Code session — type `/cloneClaudeConversation`, `/newClaudeTab`, or `/newClaudeWindow`.

## Requirements

- macOS with **Apple Terminal** as the active terminal (`$TERM_PROGRAM=Apple_Terminal`). Other terminals aren't wired up yet — patches welcome.
- `claude` CLI on `$PATH`.
- Standard tools already on every Mac: `lsof`, `osascript`, `sed`, `awk`.
- For `/cloneClaudeConversation here` (the default) and `/newClaudeTab`: **macOS Accessibility permission** for `osascript` / Terminal, because the new-tab path sends Cmd+T via System Events. The first invocation may fail with `not allowed to send keystrokes (1002)` — grant permission in **System Settings → Privacy & Security → Accessibility**, then quit and relaunch Claude Code. `/cloneClaudeConversation new` and `/newClaudeWindow` don't need this permission.
