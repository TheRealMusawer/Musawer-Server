# Use an official base image with Java
FROM eclipse-temurin:17-jre

# Install ffmpeg AND netcat so the connectivity test works
RUN apt-get update && \
    apt-get install -y ffmpeg netcat-openbsd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy everything from the current directory to /app in the container
COPY . .

# Make sure main.sh is executable
RUN chmod +x main.sh

# Command to run the main.sh script
CMD ["./main.sh"]
