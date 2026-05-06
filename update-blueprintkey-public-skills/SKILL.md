---
name: update-blueprintkey-public-skills
description: Update the locally installed BlueprintKey public skills (/cloneClaudeConversation, /newClaudeTab, /newClaudeWindow, ...) by `git pull`-ing the repo they were installed from, then report any skills in the repo that aren't symlinked into `~/.claude/skills/` yet (flagging the ones added by this pull). Use when the user invokes /update-blueprintkey-public-skills, or asks to "update the public skills", "pull the latest /cloneClaudeConversation /newClaudeTab /newClaudeWindow", "update my installed BPK skills", "refresh the public-skills repo". Locates the repo by probing the script's own path and every symlink under `~/.claude/skills/` until one resolves into a clone of public-skills, then runs `git pull --ff-only` there. All public skills live in the same repo, so one pull updates them all. Requires that at least one public skill (or this skill itself) was installed via the recommended clone+symlink path; the one-line curl install has no update mechanism and this skill will say so.
---

# /update-blueprintkey-public-skills

Pulls the latest `/cloneClaudeConversation`, `/newClaudeTab`, `/newClaudeWindow`, and any other skills published in the public-skills repo by locating any clone+symlink-installed public skill, walking up to its git root, and running `git pull --ff-only` there. After pulling, also reports any skill directories in the repo that aren't symlinked into `~/.claude/skills/` yet — flagging which ones were added by this pull so the user can decide whether to set them up.

All public skills live in the same repo (`bpkey/public-skills`), so a single pull updates them all.

## How to run

```bash
~/.claude/skills/update-blueprintkey-public-skills/scripts/update.sh
```

The script:

1. Builds a list of candidate paths to probe — its own `BASH_SOURCE[0]` plus every symlink under `~/.claude/skills/` — so it doesn't depend on any one specific public skill being installed.
2. For each candidate, resolves the symlink chain (`realpath`), runs `git rev-parse --show-toplevel`, and checks whether that toplevel contains the marker file `update-blueprintkey-public-skills/SKILL.md`. The first candidate that lands inside a public-skills clone wins.
3. Records the current `HEAD`, runs `git -C <repo-root> pull --ff-only`, and records the new `HEAD`.
4. Lists every top-level dir in the repo that contains a `SKILL.md` and checks whether `~/.claude/skills/<name>` is a symlink resolving back to it.
5. For each unlinked skill, prints a ready-to-run `ln -s` command. Skills whose `SKILL.md` was newly added (or renamed in) between old and new `HEAD` are reported under "New skills added to the repo since your last pull"; pre-existing unlinked skills go under "Other skills in the repo not symlinked into `~/.claude/skills/` yet"; and skills where `~/.claude/skills/<name>` already exists as a real (non-symlink) directory — typically left over from a curl/tarball install — go under a third section that prints `rm -rf … && ln -s …` hints instead, so the user can clear the clash before symlinking.

Echo the script's stdout back to the user verbatim — including the suggested `ln -s` commands, so they can copy-paste to install any new skills they want. Don't run those `ln -s` commands without the user asking. On non-zero exit, surface the stderr message verbatim — it explains what went wrong (no clone+symlink install found, install was via curl tarball not git clone, local clone has diverged from remote, etc.).

## Caveats

- Requires that **at least one** public skill (or this skill itself) was installed via the **clone + symlink** path (option A or B in the public-skills README). If everything was installed via the curl/tarball one-liner, no candidate resolves into a git repo and the script exits non-zero, telling the user to switch install methods.
- `--ff-only` refuses to merge if the local clone has diverged from `origin/main`. Resolve any local commits by hand — don't paper over with `--no-ff` or `reset --hard`.
- The skill name is BlueprintKey-specific because it matches the public repo it points at, but the script itself is fork-agnostic — it pulls whatever remote the local clone is tracking, as long as the clone contains the `update-blueprintkey-public-skills/SKILL.md` marker file.
