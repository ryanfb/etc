#!/bin/bash

FILENAME="_drafts/$(echo "$*" | tr '[:upper:] ' '[:lower:]_').md"
echo -e "---\ntitle: $*\n---\n" > $FILENAME
vim $FILENAME
