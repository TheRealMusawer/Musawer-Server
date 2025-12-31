#!/bin/bash

LOG="logs/latest.log"
OUT="status.txt"

# Count joins and leaves
JOINS=$(grep -c "logged in with" "$LOG")
LEAVES=$(grep -c "lost connection" "$LOG")

PLAYERS=$((JOINS - LEAVES))
if [ $PLAYERS -lt 0 ]; then
  PLAYERS=0
fi

echo "players=$PLAYERS" > "$OUT"
