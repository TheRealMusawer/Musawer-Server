#!/bin/bash
echo "starting..."
cd velocity

MTOD="§7§lMusawer Server §4• §cCome Play Now §8§lBuilt By §4Musawer"
SERVERNAME="${SERVERNAME:-'Musawer Server'}"

# -------------------------------
# Test backend connectivity FIRST
# -------------------------------
echo "Testing backend connectivity to node00.mycuba.xyz:25594 ..."
nc -zv node00.mycuba.xyz 25594
echo "Backend connectivity test complete."
# -------------------------------

# Icon handling
if [ -n "$ICON" ]; then
  echo "Downloading server icon from $ICON..."
  curl -fsSL "$ICON" -o plugins/eaglerxserver/server-icon.png
  if [ $? -eq 0 ]; then
    echo "Icon downloaded successfully."
    echo "Resizing and converting to 64x64 PNG using ffmpeg..."

    ffmpeg -i "plugins/eaglerxserver/server-icon.png" -vf scale=64:64 -frames:v 1 -update 1 "plugins/eaglerxserver/server-icon.png"

    if [ $? -eq 0 ]; then
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

# Replace ${SERVER} in velocity.toml
sed -i "s|\${SERVER}|$SERVER|g" velocity.toml

# Update listeners.toml MOTD
cd plugins/eaglerxserver
sed -i "s|\${MTOD}|$MTOD|g" listeners.toml

# Update EaglerWeb HTML branding
cd ../eaglerweb/web
sed -i 's/${SERVERNAME}/'"$SERVERNAME"'/g' game.html
sed -i 's/${SERVERNAME}/'"$SERVERNAME"'/g' wasm.html
sed -i 's/${SERVERNAME}/'"$SERVERNAME"'/g' beta.html

# Return to Velocity root
cd ../../../

# -------------------------------
# Start Velocity
# -------------------------------
echo "Starting Velocity..."
java -Xmx1024M -Xms1024M -jar server.jar
