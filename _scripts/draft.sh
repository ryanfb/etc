#!/bin/bash

FILENAME="_drafts/$(echo "$*" | tr '[:upper:] ' '[:lower:]_').md"
mkdir -p _drafts
echo -e "---\ntitle: $*\n---\n" > "$FILENAME"
vim $FILENAME
