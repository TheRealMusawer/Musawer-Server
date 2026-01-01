FROM eclipse-temurin:17-jre

WORKDIR /server

# Copy Velocity config + plugins
COPY velocity ./velocity

# Download Velocity JAR
ADD https://api.papermc.io/v2/projects/velocity/versions/3.1.2/builds/212/downloads/velocity-3.1.2-212.jar velocity.jar

EXPOSE 25565

CMD ["java", "-Xms512M", "-Xmx1G", "-jar", "velocity.jar"]
