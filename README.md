# Skills

A small collection of [Claude Code](https://claude.com/claude-code) helpers — Apple Terminal shims that fill gaps the built-in commands don't cover.

- **`/claude-samefolder [tab|window]`** — opens a fresh `claude` session in a new Terminal tab (default) or window, `cd`'d into your current project. (Plain Cmd+T lands in `~`.)
- **`/claude-forkchat [tab|window]`** — forks the *current* conversation alongside this one. Like built-in `/branch`, but keeps both threads alive instead of swapping the current terminal into the fork. Backed by `claude --resume <id> --fork-session`.

## Install

```bash
npx skills add bpkey/skills -y -g
```

Auto-detects every AI client on the machine (Claude Code, Cursor, Codex, Windsurf, …) and drops the skills into each one's well-known directory.

Update later with `npx skills update`. Single skill: `npx skills add bpkey/skills -s <skill-name> -y -g`. Full docs: <https://github.com/vercel-labs/skills>.

## Requirements

Most skills here are macOS-only for now. Each skill checks its own prerequisites and tells you what to do if something's missing (e.g. extra OS permissions on first run) — no need to set anything up in advance.
