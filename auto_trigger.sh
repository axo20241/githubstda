#!/bin/bash

# ============================================================================
# AUTO TRIGGER SCRIPT - Append Timestamp & Trigger GitHub Actions
# ============================================================================
# Description:
#   This script automatically appends timestamp data to trigger/test.txt
#   and then runs push_to_all.sh to push changes to all remotes.
#   
#   Since all GitHub Actions are push-based, this change triggers all
#   workflow runs across all remote repositories.
#
# Usage:
#   ./auto_trigger.sh
#
# Features:
#   - Appends current timestamp to trigger/test.txt
#   - Automatically commits and pushes via push_to_all.sh
#   - Sends Slack notifications on success/failure
#   - Includes error handling and logging
#
# ============================================================================

set -e  # Exit on error

TRIGGER_FILE="trigger/test.txt"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PUSH_SCRIPT="$SCRIPT_DIR/push_to_all.sh"

echo "============================================================================"
echo "AUTO TRIGGER - Appending timestamp and triggering GitHub Actions"
echo "============================================================================"
echo ""

# Check if trigger file exists
if [ ! -f "$TRIGGER_FILE" ]; then
    echo "[✗] Error: Trigger file '$TRIGGER_FILE' not found"
    exit 1
fi

# Check if push_to_all.sh exists
if [ ! -f "$PUSH_SCRIPT" ]; then
    echo "[✗] Error: Push script '$PUSH_SCRIPT' not found"
    exit 1
fi

# Generate timestamp data
TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
UNIX_TIME=$(date +'%s')
FORMATTED_ENTRY="[Trigger] $TIMESTAMP (Unix: $UNIX_TIME)"

echo "[*] Current timestamp: $TIMESTAMP"
echo "[*] Unix time: $UNIX_TIME"
echo ""

# Append timestamp to trigger file
echo "[*] Appending trigger data to '$TRIGGER_FILE'..."
echo "$FORMATTED_ENTRY" >> "$TRIGGER_FILE"

if [ $? -ne 0 ]; then
    echo "[✗] Failed to append to trigger file"
    exit 1
fi

echo "[✓] Successfully appended trigger data"
echo ""

# Display updated file content
echo "[*] Updated trigger file content:"
echo "---"
cat "$TRIGGER_FILE"
echo "---"
echo ""

# Run push_to_all.sh
echo "[*] Running push_to_all.sh to trigger GitHub Actions..."
echo ""

if bash "$PUSH_SCRIPT"; then
    echo ""
    echo "============================================================================"
    echo "[✓] AUTO TRIGGER COMPLETED SUCCESSFULLY"
    echo "============================================================================"
    echo ""
    echo "Summary:"
    echo "  - Trigger file updated: $TRIGGER_FILE"
    echo "  - Timestamp added: $FORMATTED_ENTRY"
    echo "  - Push status: SUCCESS"
    echo "  - GitHub Actions: TRIGGERED on all remotes"
    echo ""
    exit 0
else
    echo ""
    echo "============================================================================"
    echo "[✗] AUTO TRIGGER FAILED"
    echo "============================================================================"
    echo ""
    echo "The push_to_all.sh script encountered errors."
    echo "Check the output above for details."
    echo ""
    exit 1
fi
