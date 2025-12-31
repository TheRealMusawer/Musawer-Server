#!/bin/bash
echo starting...
cd velocity

MTOD="§7§lMusawer Server §4• §cCome Play Now §8§lBuilt By §4Musawer"
SERVERNAME="${SERVERNAME:-'Musawer Server'}"

if [ -n "$ICON" ]; then
  echo "Downloading server icon from $ICON..."
  curl -fsSL "$ICON" -o plugins/eaglerxserver/server-icon.png
  if [ $? -eq 0 ]; then
    echo "Icon downloaded successfully."
    echo "Resizing and converting to 64x64 PNG using ffmpeg..."

    ffmpeg -i "plugins/eaglerxserver/server-icon.png" -vf scale=64:64 -frames:v 1 -update 1 "plugins/eaglerxserver/server-icon.png"

    if [ $? -eq 0 ]; then
      mv plugins/eaglerxserver/server-icon.tmp.png plugins/eaglerxserver/server-icon.png
      echo "Icon resized and saved."
    else
      echo "Failed to resize or convert icon with ffmpeg."
    fi
  else
    echo "Failed to download icon."
  fi
else 
  echo "No icon found."
fi

sed -i 's/${SERVER}/'"$SERVER"'/g' velocity.toml

cd plugins
cd eaglerxserver

sed -i "s|\${MTOD}|$MTOD|g" listeners.toml

cd /
cd velocity
cd plugins
cd eaglerweb
cd web

sed -i 's/${SERVERNAME}/'"$SERVERNAME"'/g' game.html
sed -i 's/${SERVERNAME}/'"$SERVERNAME"'/g' wasm.html
sed -i 's/${SERVERNAME}/'"$SERVERNAME"'/g' beta.html

cd /
cd velocity

###############################################
# STATUS.TXT AUTO-UPDATER (NO JAVA REQUIRED)
###############################################

# Create update_status.sh if it doesn't exist
cat << 'EOF' > update_status.sh
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
