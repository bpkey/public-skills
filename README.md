# Skills

AI skills to get more done.

- **`/claude-samefolder [tab|window]`** — opens a fresh `claude` session in a new Terminal tab (default) or window, `cd`'d into your current project. (Plain Cmd+T lands in `~`.)
- **`/claude-forkchat [tab|window]`** — forks the *current* conversation alongside this one. Like built-in `/branch`, but keeps both threads alive instead of swapping the current terminal into the fork. Backed by `claude --resume <id> --fork-session`.

## Install

**Install all skills from this repo:**

```bash
npx skills add bpkey/skills -y -g
```

**Install a single skill:**

```bash
npx skills add bpkey/skills -s <skill-name> -y -g
```

Replace `<skill-name>` with the folder name (e.g. `claude-forkchat`).

**Update:**

```bash
npx skills update
```

**Uninstall:**

```bash
npx skills remove <skill-name> [<skill-name> ...] -y -g
```

## Requirements

Each skill checks its own prerequisites and tells you what to do if something's missing (e.g. extra OS permissions on first run) — no need to set anything up in advance.
