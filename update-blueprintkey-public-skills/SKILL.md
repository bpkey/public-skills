---
name: update-blueprintkey-public-skills
description: Update the locally installed BlueprintKey public skills (/clone, /newTab, /newWindow, ...) by `git pull`-ing the repo they were installed from, then report any skills in the repo that aren't symlinked into `~/.claude/skills/` yet (flagging the ones added by this pull). Use when the user invokes /update-blueprintkey-public-skills, or asks to "update the public skills", "pull the latest /clone /newTab /newWindow", "update my installed BPK skills", "refresh the public-skills repo". Resolves the symlink at `~/.claude/skills/clone` to its real path on disk, finds the git repo root that contains it, and runs `git pull --ff-only` there. All public skills live in the same repo, so one pull updates them all. Requires that /clone was installed via the recommended clone+symlink path; the one-line curl install has no update mechanism and this skill will say so.
---

# /update-blueprintkey-public-skills

Pulls the latest `/clone`, `/newTab`, `/newWindow`, and any other skills published in the public-skills repo, by following the symlink at `~/.claude/skills/clone` back to its origin repo and running `git pull --ff-only` there. After pulling, also reports any skill directories in the repo that aren't symlinked into `~/.claude/skills/` yet — flagging which ones were added by this pull so the user can decide whether to set them up.

All public skills live in the same repo (`bpkey/public-skills`), so a single pull updates them all.

## How to run

```bash
~/.claude/skills/update-blueprintkey-public-skills/scripts/update.sh
```

The script:

1. Resolves the symlink chain at `~/.claude/skills/clone` to its real path on disk (`realpath`).
2. Asks `git rev-parse --show-toplevel` to find the repo root that contains that path.
3. Records the current `HEAD`, runs `git -C <repo-root> pull --ff-only`, and records the new `HEAD`.
4. Lists every top-level dir in the repo that contains a `SKILL.md` and checks whether `~/.claude/skills/<name>` is a symlink resolving back to it.
5. For each unlinked skill, prints a ready-to-run `ln -s` command. Skills whose `SKILL.md` was newly added (or renamed in) between old and new `HEAD` are reported under "New skills added to the repo since your last pull"; pre-existing unlinked skills go under "Other skills in the repo not symlinked into `~/.claude/skills/` yet"; and skills where `~/.claude/skills/<name>` already exists as a real (non-symlink) directory — typically left over from a curl/tarball install — go under a third section that prints `rm -rf … && ln -s …` hints instead, so the user can clear the clash before symlinking.

Echo the script's stdout back to the user verbatim — including the suggested `ln -s` commands, so they can copy-paste to install any new skills they want. Don't run those `ln -s` commands without the user asking. On non-zero exit, surface the stderr message verbatim — it explains what went wrong (skill not installed, install was via curl tarball not git clone, local clone has diverged from remote, etc.).

## Caveats

- Requires `/clone` to have been installed via the **clone + symlink** path (option A in the public-skills README). If installed via the curl/tarball one-liner, the symlink target isn't inside a git repo and the script exits non-zero, telling the user to switch install methods.
- `--ff-only` refuses to merge if the local clone has diverged from `origin/main`. Resolve any local commits by hand — don't paper over with `--no-ff` or `reset --hard`.
- The skill name is BlueprintKey-specific because it matches the public repo it points at, but the script itself is fork-agnostic — it pulls whatever remote the local clone is tracking.
