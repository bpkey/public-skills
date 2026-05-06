# Public Skills

A small collection of [Claude Code](https://claude.com/claude-code) helpers we use ourselves to work more efficiently with Claude — shared in case they help you too. Each one installs as a global skill and runs from a slash command in any Claude Code session. macOS only for now (thin shims around AppleScript / Apple Terminal).

## What's here

- **`/clone`** — fills a gap. Closest to the built-in `/branch`, but `/branch` swaps the current terminal into the fork; `/clone` keeps the original session alive in this tab and opens the fork in a sibling tab (default) or window. Backed by `claude --resume <id> --fork-session`.
- **`/newTab`** — fills a gap. Nothing native opens a cold (non-resumed) Claude session in a new Terminal *tab* in the same window. Inherits the current working directory.
- **`/newWindow`** — fills a gap. Nothing native opens a cold (non-resumed) Claude session in a new Terminal *window*. Inherits the current working directory.
- **`/update-blueprintkey-public-skills`** — pulls the latest version of all the skills above by `git pull`-ing the local clone they were installed from. Only useful with the clone+symlink install (options A or B below); the curl install has no update mechanism.

`/newTab` and `/newWindow` start fresh — no transcript carryover, but the new shell `cd`s to the same `cwd` you ran the command from, so `claude` boots into the same project context. `/clone` carries the current conversation forward (and also stays in `cwd`).

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
into ~/.claude/skills/<name>/. Then list the contents of each
~/.claude/skills/<name>/ you created so I can verify, and remind me
I can run /update-blueprintkey-public-skills (or git pull from the
clone) to update later.
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

**Install just one skill** — replace `<skill-name>` with the directory name in the repo (e.g., `clone`, `newTab`, `newWindow`):

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
  public-skills-main/clone \
  public-skills-main/newTab \
  public-skills-main/newWindow \
  public-skills-main/update-blueprintkey-public-skills
```

Re-running the same command overwrites with the latest `main`, but you'll only do that if you remember to.

After installing by any method, the skills become available in your next Claude Code session — type `/clone`, `/newTab`, `/newWindow`, or `/update-blueprintkey-public-skills`.

## Requirements

- macOS with **Apple Terminal** as the active terminal (`$TERM_PROGRAM=Apple_Terminal`). Other terminals aren't wired up yet — patches welcome.
- `claude` CLI on `$PATH`.
- Standard tools already on every Mac: `lsof`, `osascript`, `sed`, `awk`.
- For `/clone here` (the default) and `/newTab`: **macOS Accessibility permission** for `osascript` / Terminal, because the new-tab path sends Cmd+T via System Events. The first invocation may fail with `not allowed to send keystrokes (1002)` — grant permission in **System Settings → Privacy & Security → Accessibility**, then quit and relaunch Claude Code. `/clone new` and `/newWindow` don't need this permission.
