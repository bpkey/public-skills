#!/usr/bin/env bash
# Fork the current Claude Code session into a sibling Apple Terminal tab
# (default) or window. See SKILL.md for the full contract.

set -euo pipefail

err() { printf '%s\n' "$*" >&2; }

mode="${1:-tab}"
case "$mode" in
    tab|window) ;;
    *)
        err "claude-forkchat: unknown mode '$mode' (expected 'tab' or 'window')"
        exit 2
        ;;
esac

# 1. Resolve the current session ID.
#    The Bash tool spawns shells whose $PPID is the host `claude` process,
#    which holds the live transcript JSONL open for writing. lsof tells us which.
session_path=""
if command -v lsof >/dev/null 2>&1; then
    session_path="$(lsof -p "$PPID" 2>/dev/null | awk '/\.jsonl$/ {print $NF}' | head -1 || true)"
fi

# Fallback: most recently modified transcript under the encoded-cwd project dir.
if [[ -z "$session_path" ]]; then
    encoded_cwd="$(printf '%s' "$PWD" | sed 's|/|-|g')"
    project_dir="$HOME/.claude/projects/$encoded_cwd"
    if [[ -d "$project_dir" ]]; then
        session_path="$(ls -t "$project_dir"/*.jsonl 2>/dev/null | head -1 || true)"
    fi
fi

if [[ -z "$session_path" || ! -f "$session_path" ]]; then
    err "claude-forkchat: could not locate the current session's transcript file."
    err "       checked lsof -p \$PPID and ~/.claude/projects/<encoded-cwd>/"
    exit 1
fi

session_id="$(basename "$session_path" .jsonl)"

quoted_pwd="$(printf '%q' "$PWD")"
inner_cmd="cd $quoted_pwd && claude --resume $session_id --fork-session"

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
            err "claude-forkchat: 'tab' mode needs macOS Accessibility permission to send Cmd+T."
            err "       1. System Settings → Privacy & Security → Accessibility"
            err "       2. Enable Terminal and claude (click + to add if missing — \`which claude\` shows the path)"
            err "       3. Quit and relaunch Claude Code so the new permission takes effect"
            err "       Or use \`/claude-forkchat window\` (no Accessibility needed)."
        fi
        return $status
    fi
}

term="${TERM_PROGRAM:-}"
if [[ -n "$term" && "$term" != "Apple_Terminal" ]]; then
    err "claude-forkchat: TERM_PROGRAM=$term not yet supported, falling back to Apple Terminal"
fi

case "$mode" in
    window)
        open_in_new_window "$inner_cmd"
        printf 'forked from %s into new window\n' "$session_id"
        ;;
    tab)
        front_count="$(osascript -e 'tell application "Terminal" to count windows' 2>/dev/null || echo 0)"
        if [[ "${front_count:-0}" -eq 0 ]]; then
            err "claude-forkchat: no front Terminal window — opening a new window instead"
            open_in_new_window "$inner_cmd"
            printf 'forked from %s into new window (no front window for tab)\n' "$session_id"
        else
            open_in_new_tab "$inner_cmd"
            printf 'forked from %s into new tab\n' "$session_id"
        fi
        ;;
esac
