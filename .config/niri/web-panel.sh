#!/usr/bin/env bash
# Toggle a logged-in web app as a floating side panel.
#
#   web-panel.sh chatgpt   -> ChatGPT, temporary chat (nothing saved to history)
#   web-panel.sh gemini    -> Gemini
#   web-panel.sh claude    -> Claude
#
# A real logged-in session - no API key, no subscription tier. Each panel keeps
# its own profile dir so the logins persist and never touch your normal browsing.
#
# Chrome rather than Zen, deliberately: Chrome's --app gives a chromeless window
# (no tab strip, no URL bar), which is what makes it read as a panel. Zen is
# Firefox-based and dropped --app; --new-window keeps full browser chrome, and
# running it under a separate profile + MOZ_APP_REMOTINGNAME proved flaky on
# relaunch. Zen stays your default browser - this is only the panel.
#
# Chrome ignores --class on Wayland and derives app_id from the URL, e.g.
# "chrome-chatgpt.com__-Default", which is what the niri rule matches.

set -u

case "${1:-chatgpt}" in
    chatgpt) URL="https://chatgpt.com/?temporary-chat=true" ; MATCH="chrome-chatgpt\\.com"        ; NAME="chatgpt" ;;
    gemini)  URL="https://gemini.google.com/app"            ; MATCH="chrome-gemini\\.google\\.com"; NAME="gemini"  ;;
    claude)  URL="https://claude.ai/new"                    ; MATCH="chrome-claude\\.ai"          ; NAME="claude"  ;;
    *)       URL="$1"                                       ; MATCH="chrome-"                     ; NAME="web"     ;;
esac

PROFILE="$HOME/.local/share/web-panels/$NAME"

# Already open? Focus it; if it is already focused, close it (toggle).
existing=$(niri msg -j windows 2>/dev/null \
    | jq -r --arg m "$MATCH" 'first(.[] | select(.app_id | test($m))) | "\(.id) \(.pid) \(.is_focused)"' 2>/dev/null)

if [ -n "$existing" ] && [ "$existing" != "null" ]; then
    read -r wid pid focused <<<"$existing"
    if [ "$focused" = "true" ]; then
        kill "$pid" 2>/dev/null          # by pid - never a bare close-window
    else
        niri msg action focus-window --id "$wid"
    fi
    exit 0
fi

mkdir -p "$PROFILE"
exec google-chrome-stable \
    --app="$URL" \
    --user-data-dir="$PROFILE" \
    --ozone-platform=wayland \
    >/dev/null 2>&1
