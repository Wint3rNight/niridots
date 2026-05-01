#!/usr/bin/env bash

# Use rofi to get the search query
QUERY=$(rofi -dmenu -p "Google Search")

# If the query is not empty, open it in the default browser
if [ -n "$QUERY" ]; then
    # Encode the query for URL usage
    ENCODED_QUERY=$(echo "$QUERY" | sed 's/ /+/g')
    xdg-open "https://www.google.com/search?q=$ENCODED_QUERY"
fi
