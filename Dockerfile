FROM eclipse-temurin:17-jre AS runtime

# ---- Layer 1: System dependencies (cached forever unless this line changes) ----
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# ---- Layer 2: Set working directory ----
WORKDIR /app

# ---- Layer 3: Copy only dependency files first (best caching) ----
COPY velocity/velocity.toml velocity/velocity.toml
COPY velocity/forwarding.secret velocity/forwarding.secret

# ---- Layer 4: Copy plugin configs separately (cached unless changed) ----
COPY velocity/plugins/eaglerxserver/ velocity/plugins/eaglerxserver/
COPY velocity/plugins/eaglerweb/web/ velocity/plugins/eaglerweb/web/

# ---- Layer 5: Copy the rest of Velocity (server.jar etc.) ----
COPY velocity/server.jar velocity/server.jar
COPY velocity/server-icon.png velocity/server-icon.png

# ---- Layer 6: Copy your scripts (changes often, so placed LAST) ----
COPY main.sh main.sh
RUN chmod +x main.sh

# ---- Layer 7: Copy everything else (rarely changes, but still cached) ----
COPY . .

CMD ["./main.sh"]
