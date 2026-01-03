# Use an official base image with Java
FROM eclipse-temurin:17-jre

# Install ffmpeg AND netcat so the connectivity test works
RUN apt-get update && \
    apt-get install -y ffmpeg netcat-openbsd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy core files that rarely change FIRST (keeps Docker cache alive)
COPY main.sh .
COPY forwarding.secret .

# Copy Velocity config folder structure
COPY velocity/velocity.toml ./velocity/velocity.toml

# Copy Velocity plugins
COPY velocity/plugins ./velocity/plugins

# Copy the rest LAST (only this layer rebuilds when you change files)
COPY . .

# Make sure main.sh is executable
RUN chmod +x main.sh

# Command to run the main.sh script
CMD ["./main.sh"]
