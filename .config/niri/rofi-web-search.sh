#!/usr/bin/env bash
# Ask for a search query in rofi and open it in the default browser.

QUERY=$(rofi -dmenu -p "Google Search")
[ -n "$QUERY" ] || exit 0

# Percent-encode the query so &, #, %, ?, + and non-ASCII survive the URL.
ENCODED=$(printf '%s' "$QUERY" | jq -sRr @uri)
xdg-open "https://www.google.com/search?q=$ENCODED"
