#!/bin/bash
echo "Starting..."

###############################################
# ENTER velocity/ FOLDER
###############################################
cd velocity || { echo "velocity folder missing"; exit 1; }

###############################################
# STATIC VALUES
###############################################
MTOD="§7§lMusawer Server §4• §cCome Play Now §8§lBuilt By §4Musawer"
SERVERNAME="${SERVERNAME:-Musawer Server}"

###############################################
# ICON HANDLING
###############################################
if [ -n "$ICON" ]; then
  echo "Downloading server icon from $ICON..."
  mkdir -p plugins/eaglerxserver
  curl -fsSL "$ICON" -o plugins/eaglerxserver/server-icon.png
  if [ $? -eq 0 ]; then
    echo "Icon downloaded successfully."
    ffmpeg -i "plugins/eaglerxserver/server-icon.png" -vf scale=64:64 -frames:v 1 "plugins/eaglerxserver/server-icon.png"
    echo "Icon resized."
  else
    echo "Failed to download icon."
  fi
else
  echo "No icon found."
fi

###############################################
# PATCH LISTENERS.TOML
###############################################
if [ -f plugins/eaglerxserver/listeners.toml ]; then
  sed -i "s|\${MTOD}|$MTOD|g" plugins/eaglerxserver/listeners.toml
fi

###############################################
# PATCH WEB FILES
###############################################
if [ -d plugins/eaglerweb/web ]; then
  cd plugins/eaglerweb/web || exit 1
  for f in game.html wasm.html beta.html; do
    if [ -f "$f" ]; then
      sed -i "s|\${SERVERNAME}|$SERVERNAME|g" "$f"
    fi
  done
  cd ../../../
fi

###############################################
# STATUS.TXT AUTO-UPDATER
###############################################
cat << 'EOF' > update_status.sh
#!/bin/bash

LOG="logs/latest.log"
OUT="status.txt"

if [ ! -f "$LOG" ]; then
  echo "players=0" > "$OUT"
  exit 0
fi

JOINS=$(grep -c "logged in with" "$LOG")
LEAVES=$(grep -c "lost connection" "$LOG")

PLAYERS=$((JOINS - LEAVES))
if [ $PLAYERS -lt 0 ]; then
  PLAYERS=0
fi

echo "players=$PLAYERS" > "$OUT"
EOF

chmod +x update_status.sh

# Run updater in background
while true; do
  bash update_status.sh
  sleep 5
done &

###############################################
# START VELOCITY
###############################################
echo "Launching Velocity..."

# IMPORTANT: exec replaces the shell so Render detects the process
exec java -Xms512M -Xmx512M -jar server.jar
