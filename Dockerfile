# Use an official base image with Java
FROM eclipse-temurin:17-jre

RUN apt-get update && \
    apt-get install -y ffmpeg netcat-openbsd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY main.sh .
COPY velocity/ ./velocity/

RUN chmod +x main.sh

RUN mkdir -p /data

VOLUME ["/data"]

CMD ["./main.sh"]
