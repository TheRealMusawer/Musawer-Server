# Use an official base image with Java
FROM eclipse-temurin:17-jre

# Install ffmpeg AND netcat so the connectivity test works
RUN apt-get update && \
    apt-get install -y ffmpeg netcat-openbsd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy ONLY the files that actually change
COPY main.sh .
COPY config/ ./config/
COPY scripts/ ./scripts/

# Make sure main.sh is executable
RUN chmod +x main.sh

# Create persistent storage directory
RUN mkdir -p /data

# Use /data as the server root
VOLUME ["/data"]

# Start the server
CMD ["./main.sh"]
