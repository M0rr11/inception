# Developer Documentation

## Prerequisites

The project requires:

* Linux
* Docker
* Docker Compose
* GNU Make

Check the installation with:

```bash
docker --version
docker compose version
make --version
```

## Configuration

General environment variables are stored in:

```text
srcs/.env
```

Sensitive credentials are stored as Docker Secrets:

```text
secrets/
├── credentials.txt
├── db_password.txt
└── db_root_password.txt
```

These files must contain the required credentials before starting the project.

## Build and Launch

From the repository root:

```bash
make
```

The Makefile creates the persistent data directories and runs:

```bash
docker compose -f srcs/docker-compose.yml up --build -d
```

The Compose file builds three services:

```text
nginx
wordpress
mariadb
```

## Useful Commands

Stop the containers:

```bash
make down
```

Check containers:

```bash
docker ps
```

View logs:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

Inspect the network:

```bash
docker network inspect inception
```

List volumes:

```bash
docker volume ls
```

Rebuild the project:

```bash
make re
```

## Data and Persistence

The project uses two persistent volumes:

```text
db_data
wp_data
```

They store their data in:

```text
/home/ayhakimi/data/mariadb
/home/ayhakimi/data/wordpress
```

MariaDB uses:

```text
/var/lib/mysql
```

and WordPress uses:

```text
/var/www/wordpress
```

The persistent data remains when containers are stopped or recreated.

Using `make fclean` removes the persistent data and should only be used when a complete reset is intended.
