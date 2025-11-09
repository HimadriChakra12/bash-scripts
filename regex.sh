#!/usr/bin/env bash

url="$1"
no_end="$2"    # "true" or "false"

if [ -z "$url" ]; then
    echo "Usage: $0 <url> [has_end true|false] [no_end true|false]"
    exit 1
fi

escaped=$(printf '%s' "$url" | sed -e 's/[.[\*^$()+?{|]/\\&/g' -e 's/\\/\\\\/g' -e 's/\//\\\//g')

if [ "$no_end" = "true" ]; then
    regex="^${escaped}.*$"
else
    regex="^${escaped}\$"
fi

echo "$regex"

