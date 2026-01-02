FROM eclipse-temurin:17-jre AS runtime

# ---- Layer 1: System dependencies ----
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# ---- Layer 2: Set working directory ----
WORKDIR /app

# ---- Layer 3: Copy Velocity core configs ----
COPY velocity/velocity.toml velocity/velocity.toml
COPY velocity/forwarding.secret velocity/forwarding.secret

# ---- Layer 4: Copy plugin configs ----
COPY velocity/plugins/eaglerxserver/ velocity/plugins/eaglerxserver/
COPY velocity/plugins/eaglerweb/web/ velocity/plugins/eaglerweb/web/

# ---- Layer 5: Copy Velocity runtime files ----
COPY velocity/server.jar velocity/server.jar
COPY velocity/server-icon.png velocity/server-icon.png

# ---- Layer 6: Copy scripts ----
COPY main.sh main.sh
RUN chmod +x main.sh

# ---- IMPORTANT: Do NOT copy the entire repo ----
# COPY . .   <-- REMOVED (this caused 4–10GB cache bloat)

# ---- Expose Velocity port ----
EXPOSE 25577

# ---- Start script ----
CMD ["./main.sh"]
