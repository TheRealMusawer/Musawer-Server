FROM eclipse-temurin:17-jre AS runtime

# ---- System dependencies ----
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# ---- Working directory ----
WORKDIR /app

# ---- Copy ENTIRE velocity folder (your real proxy) ----
COPY velocity/ velocity/

# ---- Copy main.sh (your real entrypoint) ----
COPY main.sh main.sh
RUN chmod +x main.sh

# ---- Expose the port your supervisor listens on ----
EXPOSE 25577

# ---- Start the supervisor, NOT Velocity ----
CMD ["./main.sh"]
