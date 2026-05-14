#!/usr/bin/env bash
# Fork the current Claude Code session into a sibling Terminal pane/window.
# See SKILL.md in this directory for the full contract.

set -euo pipefail

err() { printf '%s\n' "$*" >&2; }

mode="${1:-here}"
case "$mode" in
    here|new) ;;
    *)
        err "claude-clone-conversation: unknown mode '$mode' (expected 'here' for a new tab in the current window, or 'new' for a new window)"
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
    err "claude-clone-conversation: could not locate the current session's transcript file."
    err "       checked lsof -p \$PPID and ~/.claude/projects/<encoded-cwd>/"
    exit 1
fi

session_id="$(basename "$session_path" .jsonl)"

# 2. Build the command the new tab/window will execute.
#    printf %q escapes $PWD safely for re-evaluation in a shell.
quoted_pwd="$(printf '%q' "$PWD")"
inner_cmd="cd $quoted_pwd && claude --resume $session_id --fork-session"

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
        # Always surface the underlying AppleScript / osascript error verbatim.
        printf '%s\n' "$err_output" >&2
        # Recognised first-run error — append actionable setup hint, but keep
        # the raw error above so the user still sees what macOS actually said.
        if [[ "$err_output" == *"not allowed to send keystrokes"* ]]; then
            err ""
            err "claude-clone-conversation: 'here' mode needs macOS Accessibility permission to send Cmd+T."
            err "       1. System Settings → Privacy & Security → Accessibility"
            err "       2. Enable Terminal and claude (click + to add if missing — \`which claude\` shows the path)"
            err "       3. Quit and relaunch Claude Code so the new permission takes effect"
            err "       Or use \`/claude-clone-conversation new\` (opens a new window, no Accessibility needed)."
        fi
        return $status
    fi
}

# 3. Dispatch.
term="${TERM_PROGRAM:-}"
if [[ -n "$term" && "$term" != "Apple_Terminal" ]]; then
    err "claude-clone-conversation: TERM_PROGRAM=$term not yet supported, falling back to Apple Terminal"
fi

case "$mode" in
    new)
        open_in_new_window "$inner_cmd"
        printf 'forked from %s into new window\n' "$session_id"
        ;;
    here)
        # Need a front Terminal window to add a tab to. If none, fall back to a
        # new window so the command always lands somewhere visible.
        front_count="$(osascript -e 'tell application "Terminal" to count windows' 2>/dev/null || echo 0)"
        if [[ "${front_count:-0}" -eq 0 ]]; then
            err "claude-clone-conversation: no front Terminal window — opening a new window instead"
            open_in_new_window "$inner_cmd"
            printf 'forked from %s into new window (no front window for tab)\n' "$session_id"
        else
            open_in_new_tab "$inner_cmd"
            printf 'forked from %s into new tab\n' "$session_id"
        fi
        ;;
esac
