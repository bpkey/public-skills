#!/usr/bin/env bash
# Resolve the /clone skill's symlink chain to the local clone of the
# public-skills repo and `git pull --ff-only` there. All three skills (clone,
# newTab, newWindow) live in the same repo, so one pull updates them all.

set -euo pipefail

err() { printf '%s\n' "$*" >&2; }

skill_link="${HOME}/.claude/skills/clone"

if [[ ! -e "$skill_link" ]]; then
    err "update-blueprintkey-public-skills: ${skill_link} does not exist."
    err "       Install /clone first — see https://github.com/bpkey/public-skills"
    exit 1
fi

# Follow every level of the symlink chain to the real on-disk path.
target="$(realpath "$skill_link")"

# Find the git toplevel above that path; this is the local clone of public-skills.
repo_root="$(git -C "$target" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
    err "update-blueprintkey-public-skills: ${target} is not inside a git repo."
    err "       /clone was likely installed via the curl/tarball method, which has no update mechanism."
    err "       Reinstall via 'git clone' (option 1 in the public-skills README) to enable updates."
    exit 1
fi

printf 'pulling updates in %s\n' "$repo_root"
git -C "$repo_root" pull --ff-only
