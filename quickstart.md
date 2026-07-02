# CyberGridML App — Quickstart

This guide explains how to install and start the CyberGridML application with Podman Compose.

The application and the PostgreSQL database both run in containers. Java does not need to be installed on the host machine.

## Prerequisites

Before starting, make sure the following tools are installed:

* Podman
* `podman compose` or `podman-compose`

## Expected project structure

The project directory should contain the following files:

```text
.
├── cybergridml-app.jar
├── Dockerfile
├── compose.yaml
├── .env
└── data/
    └── postgres/
```

The `data/postgres` directory is used to persist PostgreSQL data on the local disk.

## Environment configuration

Create a `.env` file with the following content:

```env
POSTGRES_USER=dbuser
POSTGRES_PASSWORD=dbpwd
POSTGRES_DB=cybergrid-db

APP_PORT=9090
DB_PORT=5433

POSTGRES_DATA_DIR=./data/postgres
APP_DATA_DIR=./data
```

## Dockerfile

Create a `Dockerfile` with the following content:

```dockerfile
FROM docker.io/library/eclipse-temurin:17-jre

WORKDIR /app

COPY cybergridml-app.jar app.jar

EXPOSE 9090

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

## Compose configuration

Create a `compose.yaml` file with the following content:

```yaml
services:
  db:
    image: docker.io/library/postgres:15
    container_name: cybergrid-db
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    ports:
      - "${DB_PORT}:5432"
    volumes:
      - "${POSTGRES_DATA_DIR}:/var/lib/postgresql/data:Z"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 5s
      timeout: 3s
      retries: 10

  app:
    build: .
    container_name: cybergrid-app
    depends_on:
      db:
        condition: service_healthy
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://db:5432/${POSTGRES_DB}
      SPRING_DATASOURCE_USERNAME: ${POSTGRES_USER}
      SPRING_DATASOURCE_PASSWORD: ${POSTGRES_PASSWORD}
    ports:
      - "${APP_PORT}:9090"
```

## Prepare the local data directory

Create the local directory used by PostgreSQL to store data:

```bash
mkdir -p data/postgres
```

It is recommended to exclude this directory from Git.

Add the following entry to `.gitignore`:

```gitignore
data/
```

## Start the application

From the project directory, run:

```bash
podman compose up -d --build
```

If `podman compose` is not available, use:

```bash
podman-compose up -d --build
```

This command:

* builds the application container image;
* starts the PostgreSQL database;
* starts the CyberGridML application;
* stores PostgreSQL data in the local `data/postgres` directory.

## Check running containers

```bash
podman ps
```

The following containers should be running:

* `cybergrid-db`
* `cybergrid-app`

## View logs

Application logs:

```bash
podman logs -f cybergrid-app
```

PostgreSQL logs:

```bash
podman logs -f cybergrid-db
```

## Stop the application

To stop the containers without deleting PostgreSQL data:

```bash
podman compose down
```

Or, if using `podman-compose`:

```bash
podman-compose down
```

## Remove local PostgreSQL data

Warning: this deletes the local PostgreSQL database files.

First stop the containers:

```bash
podman compose down
```

Then remove the local data directory:

```bash
rm -rf data/postgres
```

## Application URL

Once the startup is complete, the application is available at:

```text
http://localhost:9090
```
