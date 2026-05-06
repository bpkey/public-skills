#!/usr/bin/env bash
# Locate the local clone of the public-skills repo by probing the script's own
# path and every symlink under ~/.claude/skills/, then `git pull --ff-only`
# there. All skills in the repo share the same clone, so one pull updates them
# all. After pulling, also report any skill directories in the repo that aren't
# symlinked into ~/.claude/skills/ yet — flagging the ones added by this pull.

set -euo pipefail

err() { printf '%s\n' "$*" >&2; }

# Marker file present at the toplevel of any clone of public-skills. Used to
# distinguish our repo from any other git repo a symlinked skill might live in.
marker="update-blueprintkey-public-skills/SKILL.md"

# Build candidate paths to probe for the repo root. We can't assume any one
# specific skill is installed (the user may have installed only a subset), so
# try several anchors and use the first one that lands in our repo.
candidates=()
# 1. This script's own path. If update-blueprintkey-public-skills was installed
#    via clone+symlink, BASH_SOURCE[0] resolves into the repo.
candidates+=("${BASH_SOURCE[0]}")
# 2. Every symlink under ~/.claude/skills/. If any public skill was installed
#    via clone+symlink, its target's git toplevel is the repo we want.
shopt -s nullglob
for entry in "${HOME}/.claude/skills"/*; do
    [[ -L "$entry" ]] && candidates+=("$entry")
done
shopt -u nullglob

repo_root=""
for c in "${candidates[@]}"; do
    target="$(realpath "$c" 2>/dev/null || true)"
    [[ -z "$target" ]] && continue
    # `git -C` needs a directory.
    [[ -d "$target" ]] || target="$(dirname "$target")"
    root="$(git -C "$target" rev-parse --show-toplevel 2>/dev/null || true)"
    [[ -z "$root" ]] && continue
    [[ -f "$root/$marker" ]] || continue
    repo_root="$root"
    break
done

if [[ -z "$repo_root" ]]; then
    err "update-blueprintkey-public-skills: could not locate a clone+symlink install of any public-skill."
    err "       Probed this script's own path and every symlink under ~/.claude/skills/."
    err "       The skills were likely installed via the curl/tarball method, which has no update mechanism."
    err "       Reinstall via 'git clone' (option A or B in the public-skills README) to enable updates."
    exit 1
fi

old_head="$(git -C "$repo_root" rev-parse HEAD)"

printf 'pulling updates in %s\n' "$repo_root"
git -C "$repo_root" pull --ff-only

new_head="$(git -C "$repo_root" rev-parse HEAD)"

# All top-level dirs in the repo that contain a SKILL.md — i.e. installable skills.
skill_dirs=()
while IFS= read -r path; do
    skill_dirs+=("${path%/SKILL.md}")
done < <(find "$repo_root" -mindepth 2 -maxdepth 2 -name SKILL.md -type f -print | sort)

# Skills whose SKILL.md was added between old and new HEAD — i.e. brand new in this pull.
added_paths=()
if [[ "$old_head" != "$new_head" ]]; then
    while IFS= read -r path; do
        case "$path" in
            */SKILL.md) added_paths+=("$repo_root/${path%/SKILL.md}");;
        esac
    done < <(git -C "$repo_root" diff --name-only --diff-filter=AR "$old_head" "$new_head")
fi

is_added() {
    local needle="$1"
    if (( ${#added_paths[@]} == 0 )); then return 1; fi
    local p
    for p in "${added_paths[@]}"; do
        [[ "$p" == "$needle" ]] && return 0
    done
    return 1
}

# Bucket each skill: already-linked, new-and-unlinked, pre-existing-and-unlinked,
# or clashing (a non-symlink path is already in the way at the install location).
unlinked_new=()
unlinked_old=()
clashing=()
if (( ${#skill_dirs[@]} > 0 )); then
    for dir in "${skill_dirs[@]}"; do
        name="$(basename "$dir")"
        link="${HOME}/.claude/skills/${name}"
        linked_here=0
        if [[ -e "$link" ]]; then
            resolved="$(realpath "$link" 2>/dev/null || true)"
            [[ "$resolved" == "$dir" ]] && linked_here=1
        fi
        if (( linked_here )); then
            continue
        fi
        # If something exists at $link but it's not a symlink (and therefore
        # can't be the right target), it's a clash — likely a curl/tarball
        # install. The user has to remove or rename it before symlinking.
        if [[ -e "$link" && ! -L "$link" ]]; then
            clashing+=("$name")
            continue
        fi
        if is_added "$dir"; then
            unlinked_new+=("$name")
        else
            unlinked_old+=("$name")
        fi
    done
fi

print_install_hints() {
    local name
    for name in "$@"; do
        printf '  ln -s %q %q\n' "$repo_root/$name" "${HOME}/.claude/skills/$name"
    done
}

if (( ${#unlinked_new[@]} > 0 )); then
    printf '\nNew skills added to the repo since your last pull:\n'
    for name in "${unlinked_new[@]}"; do
        printf '  - %s\n' "$name"
    done
    printf 'Symlink each into ~/.claude/skills/ to enable them:\n'
    print_install_hints "${unlinked_new[@]}"
fi

if (( ${#unlinked_old[@]} > 0 )); then
    printf '\nOther skills in the repo not symlinked into ~/.claude/skills/ yet:\n'
    for name in "${unlinked_old[@]}"; do
        printf '  - %s\n' "$name"
    done
    printf 'Symlink each into ~/.claude/skills/ to enable them:\n'
    print_install_hints "${unlinked_old[@]}"
fi

if (( ${#clashing[@]} > 0 )); then
    printf '\nThe following skills are present in the repo but ~/.claude/skills/<name> already exists as a non-symlink (likely from a curl/tarball install):\n'
    for name in "${clashing[@]}"; do
        printf '  - %s\n' "$name"
    done
    printf 'Remove or rename those paths first, then symlink the repo dir:\n'
    for name in "${clashing[@]}"; do
        printf '  rm -rf %q && ln -s %q %q\n' \
            "${HOME}/.claude/skills/$name" \
            "$repo_root/$name" \
            "${HOME}/.claude/skills/$name"
    done
fi
