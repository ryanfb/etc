#!/bin/bash

FILENAME="_posts/$(date +%F)-$(echo "$1" | tr '[:upper:] ' '[:lower:]_').md"
echo -e "---\ntitle: '$1'\nexternal_url: $2\n---" > "$FILENAME"
