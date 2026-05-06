# Public Skills

A small collection of [Claude Code](https://claude.com/claude-code) helpers we use ourselves to work more efficiently with Claude — shared in case they help you too. Each one installs as a global skill and runs from a slash command in any Claude Code session. macOS only for now (thin shims around AppleScript / Apple Terminal).

## What's here

- **`/cloneClaudeConversation`** — fills a gap. Closest to the built-in `/branch`, but `/branch` swaps the current terminal into the fork; `/cloneClaudeConversation` keeps the original session alive in this tab and opens the fork **alongside** it — in a sibling tab by default (`/cloneClaudeConversation` or `/cloneClaudeConversation here`), or in a new window with `/cloneClaudeConversation new`. Backed by `claude --resume <id> --fork-session`.
- **`/newClaudeTab`** — fills a gap. Opens a fresh (non-resumed) Claude session in a new Terminal *tab*, in the **same working directory** as the running Claude — so the new session boots straight into your current project, no manual `cd` needed. (Cmd+T natively lands in `~`.)
- **`/newClaudeWindow`** — same as `/newClaudeTab` but a new Terminal *window* instead of a tab.
- **`/update-blueprintkey-public-skills`** — pulls the latest version of all the skills above by `git pull`-ing the local clone they were installed from. Only useful with the clone+symlink install (options A or B below); the curl install has no update mechanism.

`/newClaudeTab` and `/newClaudeWindow` start fresh — no transcript carryover, but the new shell `cd`s to the same `cwd` you ran the command from, so `claude` boots into the same project context. `/cloneClaudeConversation` carries the current conversation forward (and also stays in `cwd`).

## Installing

**Recommended: option A (Via Prompting) or option B (command line).** Both leave you with a real `git clone` that you can `git pull` to pick up updates. Option C freezes a snapshot at install time — to update, you'd have to re-run the install command and remember to do so.

### A. Via Prompting

Paste this prompt into Claude Code (or any AI coding tool with shell access):

```bash
I want to install Claude Code skills from
https://github.com/bpkey/public-skills.

First, ask me where I'd like to clone the repo and wait for my answer.

Once I confirm the location, git clone it there. Then list every
top-level directory in the clone that contains a SKILL.md file —
each of those is an installable skill. Show me that list and ask
whether to install all of them or just some. If I say "some",
wait for me to reply with the names I want.

For each skill I confirm, create a symlink from the skill directory
into the skills install destination (see below). Then list the
contents of each <destination>/<name>/ you created so I can verify,
and remind me I can run /update-blueprintkey-public-skills (or git
pull from the clone) to update later.

Resilience: at every step, keep the end goal in mind — a working
install of the skills I picked. If a command errors out (clone,
mkdir, ln, readlink, ls), don't go silent and don't stop. Tell me
in plain language what failed and the likely cause, fix it
automatically when safe (examples below), or ask me one focused
question to unblock. Only abort if I explicitly say so.

Cloning, specifically:
- If the parent directory of the path I gave doesn't exist, run
  `mkdir -p` on the parent and continue — don't fail on that alone.
- If the destination already exists and is a clone of the same
  repo, treat it as already-cloned and proceed to the symlink step.
- If the destination exists but is something else, stop and ask
  me before touching it.

Skills install destination, specifically:
- Before creating any symlinks, check whether `~/.claude/skills`
  is itself a symbolic link (`readlink ~/.claude/skills`). If it
  is, resolve it and use the resolved path as the install
  destination — that's where I've chosen for my skills to live.
  Show me the resolved path before creating links so I know where
  they're going.
- If `~/.claude/skills` doesn't exist, create it (`mkdir -p`) and
  use it directly.
- Otherwise, use `~/.claude/skills` as-is.
```

### B. Command line

Run from wherever you keep your repos. The symlinks resolve via `$PWD`, so the clone destination is up to you.

**Install all skills:**

```bash
git clone https://github.com/bpkey/public-skills.git
cd public-skills
for d in */; do
  [ -f "$d/SKILL.md" ] && ln -s "$PWD/${d%/}" ~/.claude/skills/${d%/}
done
```

**Install just one skill** — replace `<skill-name>` with the directory name in the repo (e.g., `cloneClaudeConversation`, `newClaudeTab`, `newClaudeWindow`):

```bash
git clone https://github.com/bpkey/public-skills.git
cd public-skills
ln -s "$PWD/<skill-name>" ~/.claude/skills/<skill-name>
```

To update later, run `/update-blueprintkey-public-skills` from inside any Claude Code session — or `cd` back into the clone and `git pull` directly. The symlinks pick up changes automatically, no reinstall needed.

### C. Quick try — one-line curl (no clone, no updates)

Useful only for a quick taste — there's no update mechanism, so eventually switch to option A or B.

```bash
mkdir -p ~/.claude/skills && \
curl -fsSL https://github.com/bpkey/public-skills/archive/refs/heads/main.tar.gz | \
tar -xz -C ~/.claude/skills --strip-components=1 \
  public-skills-main/cloneClaudeConversation \
  public-skills-main/newClaudeTab \
  public-skills-main/newClaudeWindow \
  public-skills-main/update-blueprintkey-public-skills
```

Re-running the same command overwrites with the latest `main`, but you'll only do that if you remember to.

After installing by any method, the skills become available in your next Claude Code session — type `/cloneClaudeConversation`, `/newClaudeTab`, `/newClaudeWindow`, or `/update-blueprintkey-public-skills`.

## Requirements

- macOS with **Apple Terminal** as the active terminal (`$TERM_PROGRAM=Apple_Terminal`). Other terminals aren't wired up yet — patches welcome.
- `claude` CLI on `$PATH`.
- Standard tools already on every Mac: `lsof`, `osascript`, `sed`, `awk`.
- For `/cloneClaudeConversation here` (the default) and `/newClaudeTab`: **macOS Accessibility permission** for `osascript` / Terminal, because the new-tab path sends Cmd+T via System Events. The first invocation may fail with `not allowed to send keystrokes (1002)` — grant permission in **System Settings → Privacy & Security → Accessibility**, then quit and relaunch Claude Code. `/cloneClaudeConversation new` and `/newClaudeWindow` don't need this permission.
