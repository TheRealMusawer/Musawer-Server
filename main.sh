#!/bin/bash
echo "Starting..."
cd velocity

###############################################
# STATIC VALUES (SAFE)
###############################################

MTOD="§7§lMusawer Server §4• §cCome Play Now §8§lBuilt By §4Musawer"
SERVERNAME="${SERVERNAME:-Musawer Server}"

###############################################
# ICON HANDLING
###############################################

if [ -n "$ICON" ]; then
  echo "Downloading server icon from $ICON..."
  curl -fsSL "$ICON" -o plugins/eaglerxserver/server-icon.png
  if [ $? -eq 0 ]; then
    echo "Icon downloaded successfully."
    echo "Resizing to 64x64 using ffmpeg..."

    ffmpeg -i "plugins/eaglerxserver/server-icon.png" -vf scale=64:64 -frames:v 1 "plugins/eaglerxserver/server-icon.png"

    echo "Icon resized."
  else
    echo "Failed to download icon."
  fi
else
  echo "No icon found."
fi

###############################################
# PATCH LISTENERS.TOML (SAFE)
###############################################

cd plugins/eaglerxserver

# Only replace MTOD if placeholder exists
if grep -q "\${MTOD}" listeners.toml; then
  sed -i "s|\${MTOD}|$MTOD|g" listeners.toml
fi

###############################################
# PATCH WEB FILES (SAFE)
###############################################

cd ../../eaglerweb/web

for f in game.html wasm.html beta.html; do
  if grep -q "\${SERVERNAME}" "$f"; then
    sed -i "s|\${SERVERNAME}|$SERVERNAME|g" "$f"
  fi
done

###############################################
# RETURN TO VELOCITY ROOT
###############################################

cd ../../..

###############################################
# STATUS.TXT AUTO-UPDATER
###############################################

cat << 'EOF' > update_status.sh
#!/bin/bash

LOG="logs/latest.log"
OUT="status.txt"

JOINS=$(grep -c "logged in with" "$LOG")
LEAVES=$(grep -c "lost connection" "$LOG")

PLAYERS=$((JOINS - LEAVES))
if [ $PLAYERS -lt 0 ]; then
  PLAYERS=0
fi

echo "players=$PLAYERS" > "$OUT"
EOF

chmod +x update_status.sh

# Run updater every 5 seconds in background
while true; do
  bash update_status.sh
  sleep 5
done &

###############################################
# START VELOCITY
###############################################

java -Xmx1024M -Xms1024M -jar server.jar
