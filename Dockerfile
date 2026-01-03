# Use an official base image with Java
FROM eclipse-temurin:17-jre

# Install ffmpeg AND netcat so the connectivity test works
RUN apt-get update && \
    apt-get install -y ffmpeg netcat-openbsd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy ONLY the files you want stored in the image
# (These update when you push to GitHub)
COPY main.sh .
COPY velocity/ ./velocity/
COPY scripts/ ./scripts/
COPY eagler/ ./eagler/
COPY config/ ./config/

# Make sure main.sh is executable
RUN chmod +x main.sh

# Create persistent storage directory
# (Render keeps this forever)
RUN mkdir -p /data

# Mark /data as persistent volume
VOLUME ["/data"]

# Start the server
CMD ["./main.sh"]
