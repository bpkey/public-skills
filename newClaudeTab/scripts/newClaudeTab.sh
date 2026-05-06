#!/usr/bin/env bash
# Open a new tab in the current Apple Terminal window and start a fresh
# `claude` session in the same working directory. See SKILL.md for details.

set -euo pipefail

err() { printf '%s\n' "$*" >&2; }

if [[ $# -gt 0 ]]; then
    err "newClaudeTab: takes no arguments (got '$*')"
    exit 2
fi

# Build the command the new tab/window will execute.
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
    osascript \
        -e "tell application \"Terminal\" to do script \"$escaped\"" \
        -e 'tell application "Terminal" to activate' >/dev/null
}

open_in_new_tab() {
    local escaped err_output status
    escaped="$(escape_for_applescript "$1")"
    # Cmd+T on the front Terminal window opens a new tab; `do script ... in
    # front window` then writes to that new (now-selected) tab's fresh shell.
    set +e
    err_output=$(osascript \
        -e 'tell application "Terminal" to activate' \
        -e 'delay 0.15' \
        -e 'tell application "System Events" to tell process "Terminal" to keystroke "t" using command down' \
        -e 'delay 0.30' \
        -e "tell application \"Terminal\" to do script \"$escaped\" in front window" 2>&1 >/dev/null)
    status=$?
    set -e
    if [[ $status -ne 0 ]]; then
        printf '%s\n' "$err_output" >&2
        if [[ "$err_output" == *"not allowed to send keystrokes"* ]]; then
            err ""
            err "newClaudeTab: needs macOS Accessibility permission to send Cmd+T."
            err "        1. System Settings → Privacy & Security → Accessibility"
            err "        2. Enable Terminal and claude (click + to add if missing — \`which claude\` shows the path)"
            err "        3. Quit and relaunch Claude Code so the new permission takes effect"
        fi
        return $status
    fi
}

term="${TERM_PROGRAM:-}"
if [[ -n "$term" && "$term" != "Apple_Terminal" ]]; then
    err "newClaudeTab: TERM_PROGRAM=$term not yet supported, falling back to Apple Terminal"
fi

# Need a front Terminal window to add a tab to. If none, fall back to a new
# window so the command always lands somewhere visible.
front_count="$(osascript -e 'tell application "Terminal" to count windows' 2>/dev/null || echo 0)"
if [[ "${front_count:-0}" -eq 0 ]]; then
    err "newClaudeTab: no front Terminal window — opening a new window instead"
    open_in_new_window "$inner_cmd"
    printf 'opened new window with fresh claude in %s\n' "$PWD"
else
    open_in_new_tab "$inner_cmd"
    printf 'opened new tab with fresh claude in %s\n' "$PWD"
fi
