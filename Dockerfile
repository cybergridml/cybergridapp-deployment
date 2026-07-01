FROM docker.io/library/eclipse-temurin:17-jre

WORKDIR /app

COPY cybergridml-app.jar app.jar

EXPOSE 9090

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
