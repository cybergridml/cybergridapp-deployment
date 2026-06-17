FROM docker.io/library/eclipse-temurin:17-jre

WORKDIR /app

COPY NacreRTE-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 9090

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
