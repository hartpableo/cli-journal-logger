#!/usr/bin/env bash

set -a
source .env
set +a

MESSAGE=$1
FILE="$JOURNAL_DIR/journal_$(date +%F).log"

# If input string is empty, prompt the user with multiline text input via "nano"
if [[ -z "$MESSAGE" ]]; then
	TMP_FILE=$(mktemp)
	nano "$TMP_FILE"
	MESSAGE=$(<"$TMP_FILE")
  rm -f "$TMP_FILE"
fi

# Return error if MESSAGE is still empty
if [[ -z "$MESSAGE" ]]; then
	echo ""
	echo -e "\033[0;31mMessage is empty\033[0m"
	echo ""
	exit 1
fi

# Save to file (append)
echo "

===== $(date +"%B %d, %Y at %H:%M:%S %p") =====
$MESSAGE
" >> "$FILE"

echo ""
echo -e "\033[0;32mLog saved!\033[0m"
echo ""