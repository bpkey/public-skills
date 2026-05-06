---
name: update-blueprintkey-public-skills
description: Update the locally installed BlueprintKey public skills (/clone, /newTab, /newWindow) by `git pull`-ing the repo they were installed from. Use when the user invokes /update-blueprintkey-public-skills, or asks to "update the public skills", "pull the latest /clone /newTab /newWindow", "update my installed BPK skills", "refresh the public-skills repo". Resolves the symlink at `~/.claude/skills/clone` to its real path on disk, finds the git repo root that contains it, and runs `git pull --ff-only` there. All three public skills live in the same repo, so one pull updates them all. Requires that /clone was installed via the recommended clone+symlink path; the one-line curl install has no update mechanism and this skill will say so.
---

# /update-blueprintkey-public-skills

Pulls the latest `/clone`, `/newTab`, and `/newWindow` from wherever they were `git clone`d locally, by following the symlink at `~/.claude/skills/clone` back to its origin repo and running `git pull --ff-only` there.

All three public skills live in the same repo (`bpkey/public-skills`), so a single pull updates them all.

## How to run

```bash
~/repo/tools-config/skills/update-blueprintkey-public-skills/update.sh
```

The script:

1. Resolves the symlink chain at `~/.claude/skills/clone` to its real path on disk (`realpath`).
2. Asks `git rev-parse --show-toplevel` to find the repo root that contains that path.
3. Runs `git -C <repo-root> pull --ff-only` there.
4. Echoes the repo path it updated.

Echo the script's stdout back to the user. On non-zero exit, surface the stderr message verbatim — it explains what went wrong (skill not installed, install was via curl tarball not git clone, local clone has diverged from remote, etc.).

## Caveats

- Requires `/clone` to have been installed via the **clone + symlink** path (option 1 in the public-skills README). If installed via the curl/tarball one-liner, the symlink target isn't inside a git repo and the script exits non-zero, telling the user to switch install methods.
- `--ff-only` refuses to merge if the local clone has diverged from `origin/main`. Resolve any local commits by hand — don't paper over with `--no-ff` or `reset --hard`.
- The skill name is BlueprintKey-specific because it matches the public repo it points at, but the script itself is fork-agnostic — it pulls whatever remote the local clone is tracking.
