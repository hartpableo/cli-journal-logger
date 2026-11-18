#!/usr/bin/env bash

# Resolve the directory where the script actually resides (resolving symlinks)
SCRIPT_SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SCRIPT_SOURCE" ]; do
  SCRIPT_DIR="$(cd -P "$(dirname "$SCRIPT_SOURCE")" >/dev/null 2>&1 && pwd)"
  SCRIPT_SOURCE="$(readlink "$SCRIPT_SOURCE")"
  [[ $SCRIPT_SOURCE != /* ]] && SCRIPT_SOURCE="$SCRIPT_DIR/$SCRIPT_SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SCRIPT_SOURCE")" >/dev/null 2>&1 && pwd)"

if [[ -f "$SCRIPT_DIR/.env" ]]; then
  set -a
  source "$SCRIPT_DIR/.env"
  set +a
fi

if [[ -z "$JOURNAL_DIR" ]]; then
  echo -e "\033[0;31mError: JOURNAL_DIR is not set. Check $SCRIPT_DIR/.env\033[0m"
  exit 1
fi

mkdir -p "$JOURNAL_DIR"

FILE="$JOURNAL_DIR/journal_$(date +%F).log"

# Prompt the user with multiline text input via "nano"
TMP_FILE=$(mktemp)
nano "$TMP_FILE"
MESSAGE=$(<"$TMP_FILE")
rm -f "$TMP_FILE"

# Return error if MESSAGE is still empty
if [[ -z "$MESSAGE" ]]; then
	echo ""
	echo -e "\033[0;31mMessage is empty\033[0m"
	echo ""
	exit 1
fi

# Save to file (append)
if ! echo "
===== $(date +"%B %d, %Y at %H:%M:%S %p") =====
$MESSAGE

" >> "$FILE"; then
  echo -e "\033[0;31mFailed to save log to $FILE\033[0m"
  exit 1
fi

# Post to devnull if flagged
if echo "$*" | grep -e "--devnull" -q; then
  curl -fsSL https://dev-null.sh/commit | bash -s -- "$MESSAGE"
fi

echo ""
echo -e "\033[0;32mLog saved!\033[0m"
echo ""