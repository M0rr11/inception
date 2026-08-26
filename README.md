# Inception

*This project has been created as part of the 42 curriculum by ayhakimi.*

## Description

Inception is a system administration and Docker project from the 42 curriculum. The goal is to build a small infrastructure using Docker Compose, with separate containers for different services and persistent storage.

This project provides a WordPress website running through three services:

* **Nginx** — the web server and entry point of the infrastructure. It handles HTTPS connections on port 443 and serves the WordPress files.
* **WordPress** — the content management system running with PHP-FPM.
* **MariaDB** — the database server used by WordPress to store its data.

The services communicate through a dedicated Docker bridge network called `inception`.

### Project Architecture


                         HTTPS :443
                             │
                             ▼
                       ┌──────────┐
                       │  Nginx   │
                       └────┬─────┘
                            │
                            ▼
                      ┌───────────┐
                      │ WordPress │
                      │  PHP-FPM  │
                      └─────┬─────┘
                            │
                            ▼
                       ┌─────────┐
                       │ MariaDB │
                       └─────────┘


The three services are built from their own Dockerfiles:

```text
srcs/requirements/
├── mariadb/
│   └── Dockerfile
├── nginx/
│   └── Dockerfile
└── wordpress/
    └── Dockerfile
```

No pre-built application containers are used for these services; each service has its own image definition.

## Docker

Docker is used to isolate each service into its own container while allowing the services to communicate through a private Docker network.

The main design choices are:

* One container per service.
* Custom Dockerfiles for MariaDB, WordPress and Nginx.
* A dedicated bridge network for communication between containers.
* Docker volumes for persistent application and database data.
* Docker Secrets for sensitive passwords and credentials.
* Environment variables for non-secret configuration.
* Nginx as the only service exposed to the host.

### Docker Compose

The infrastructure is managed with Docker Compose through:

```text
srcs/docker-compose.yml
```

The Compose configuration defines:

* `mariadb`
* `wordpress`
* `nginx`
* the `inception` network
* `db_data` and `wp_data` volumes
* Docker secrets

The WordPress and MariaDB services are not directly exposed to the host. They communicate internally through the `inception` network.

## Design Choices and Comparisons

### Virtual Machines vs Docker

**Virtual Machines**

A virtual machine emulates or virtualizes an entire computer system. Each VM normally contains its own operating system, kernel, libraries and applications.

Advantages:

* Stronger isolation between complete operating systems.
* Can run different operating systems on the same physical machine.

Disadvantages:

* Higher memory and storage consumption.
* Slower startup.
* More overhead because each VM requires a complete operating system.

**Docker**

Docker containers share the host operating system kernel while isolating applications and their dependencies.

Advantages:

* Lightweight compared with full virtual machines.
* Fast startup and shutdown.
* Easy to reproduce the same application environment.
* Each service can be independently built and managed.

Disadvantages:

* Containers share the host kernel.
* Isolation is different from the isolation provided by a complete virtual machine.

For this project, Docker is appropriate because the objective is to build a small multi-service infrastructure where each service can run in its own isolated container.

### Secrets vs Environment Variables

Environment variables are useful for configuration values that do not need to remain secret. They can be provided to containers through the Compose `env_file` configuration.

Sensitive values such as passwords should not be treated in the same way because environment variables can potentially be exposed through container inspection or process environments.

This project therefore uses **Docker Secrets** for sensitive credentials:

```text
secrets/
├── credentials.txt
├── db_password.txt
└── db_root_password.txt
```

The Compose file makes these secrets available only to the services that require them.

Environment variables are used for general configuration, while Docker Secrets are used for sensitive authentication information.

### Docker Network vs Host Network

**Docker bridge network**

Containers communicate through an isolated Docker network. Services can reach each other using their Docker service/container names without exposing every service to the host.

This project uses:

```yaml
networks:
  inception:
    driver: bridge
```

Only Nginx publishes a port to the host:

```text
443:443
```

MariaDB and WordPress remain accessible through the internal Docker network.

**Host network**

With host networking, a container shares the host's network namespace. The container does not get the same type of network isolation and directly uses the host's network interfaces and ports.

The bridge network is preferred here because it provides service isolation while allowing the required communication between Nginx, WordPress and MariaDB.

### Docker Volumes vs Bind Mounts

A Docker-managed volume normally has its lifecycle managed by Docker, while a bind mount maps a specific directory from the host filesystem into a container.

This project uses Docker volume definitions backed by host directories:

```text
/home/ayhakimi/data/mariadb
/home/ayhakimi/data/wordpress
```

The Compose configuration uses local volumes with bind options to connect these directories to the containers.

MariaDB stores its data in:

```text
/var/lib/mysql
```

and WordPress uses:

```text
/var/www/wordpress
```

The host directories allow the project data to persist independently from the lifetime of the containers.

## Instructions

### Prerequisites

The project requires:

* Docker
* Docker Compose
* GNU Make
* A Linux environment capable of running Docker

The project also expects the required configuration and secret files to be present in the repository structure.

### Configuration

The Compose configuration is located at:

```text
srcs/docker-compose.yml
```

General environment configuration is stored in:

```text
srcs/.env
```

Sensitive credentials are stored as Docker Secret files in:

```text
secrets/
```

The domain used by the project is:

```text
ayhakimi.42.fr
```

### Build and Start

From the root of the repository:

```bash
make
```

or:

```bash
make up
```

The Makefile creates the persistent host directories and then builds and starts the Docker Compose infrastructure in detached mode.

### Stop the Project

```bash
make down
```

This stops and removes the Compose containers while keeping the persistent data.

### Clean Docker Resources

```bash
make clean
```

This runs the `down` target and then performs:

```bash
docker system prune -af
```

### Rebuild

```bash
make re
```

This performs a full cleanup followed by a new build and startup.

> The `fclean` target removes the persistent data directories and therefore deletes the stored MariaDB and WordPress data. Use it only when this data can safely be removed.

## Persistent Data

The project uses two persistent data locations:

```text
/home/ayhakimi/data/mariadb
/home/ayhakimi/data/wordpress
```

MariaDB data is persisted in the first directory, while WordPress data is persisted in the second.

This means that removing and recreating containers does not automatically remove the data stored in these directories.

## Services

### Nginx

Nginx is the public entry point of the stack.

It:

* Accepts HTTPS connections.
* Uses port `443`.
* Provides access to the WordPress application.
* Shares the WordPress volume with the WordPress container.

### WordPress

WordPress provides the website and runs through PHP-FPM.

It:

* Uses the `wp_data` volume.
* Connects to MariaDB through the `inception` Docker network.
* Uses the database credentials provided through Docker Secrets and environment configuration.

### MariaDB

MariaDB provides the database used by WordPress.

It:

* Uses the `db_data` volume.
* Stores persistent database information.
* Is accessible to the other containers through the `inception` Docker network.
* Uses Docker Secrets for database passwords.

## Resources

### Docker

* Docker Documentation — https://docs.docker.com/
* Docker Compose Documentation — https://docs.docker.com/compose/
* Docker Networks Documentation — https://docs.docker.com/engine/network/
* Docker Volumes Documentation — https://docs.docker.com/engine/storage/volumes/
* Docker Secrets Documentation — https://docs.docker.com/engine/swarm/secrets/

### Nginx

* Nginx Documentation — https://nginx.org/en/docs/

### WordPress

* WordPress Documentation — https://developer.wordpress.org/documentation/

### MariaDB

* MariaDB Documentation — https://mariadb.com/docs/

### Docker vs Virtual Machines

* Docker: What is a Container? — https://www.docker.com/resources/what-container/
* Docker: Containers vs Virtual Machines — https://www.docker.com/resources/docker-container-vm/

## AI Usage

AI tools were used as a learning and development aid during the project.

They were used for:

* Understanding Docker and Docker Compose concepts.
* Understanding the relationship between containers, networks and volumes.
* Troubleshooting Docker and Linux configuration issues.
* Understanding Nginx, WordPress and MariaDB interactions.
* Explaining commands and configuration behavior.
* Reviewing and improving documentation.
* Helping investigate errors encountered during development.

AI was used as a support and learning tool rather than as a replacement for understanding or implementing the project. The project's configuration, Dockerfiles, scripts and infrastructure were tested and adapted to the project's requirements.

## Project Structure

```text
.
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── Makefile
├── .gitignore
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        └── wordpress/
            ├── Dockerfile
            ├── conf/
            └── tools/
```
