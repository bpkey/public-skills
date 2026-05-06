#!/usr/bin/env bash
# Open a new Apple Terminal window and start a fresh `claude` session in the
# same working directory. See SKILL.md for details.

set -euo pipefail

err() { printf '%s\n' "$*" >&2; }

if [[ $# -gt 0 ]]; then
    err "newClaudeWindow: takes no arguments (got '$*')"
    exit 2
fi

# Build the command the new window will execute.
# printf %q escapes $PWD safely for re-evaluation in a shell.
quoted_pwd="$(printf '%q' "$PWD")"
inner_cmd="cd $quoted_pwd && claude"

# AppleScript-escape: backslashes and double quotes only.
escape_for_applescript() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

open_in_new_window() {
    local escaped
    escaped="$(escape_for_applescript "$1")"
    # `do script` with no `in window` clause always opens a brand-new window.
    osascript \
        -e "tell application \"Terminal\" to do script \"$escaped\"" \
        -e 'tell application "Terminal" to activate' >/dev/null
}

term="${TERM_PROGRAM:-}"
if [[ -n "$term" && "$term" != "Apple_Terminal" ]]; then
    err "newClaudeWindow: TERM_PROGRAM=$term not yet supported, falling back to Apple Terminal"
fi

open_in_new_window "$inner_cmd"
printf 'opened new window with fresh claude in %s\n' "$PWD"
