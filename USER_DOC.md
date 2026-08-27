# User Documentation

## Services

The project consists of three services:

* **Nginx** — HTTPS web server and the only public entry point.
* **WordPress** — website and administration panel.
* **MariaDB** — database used by WordPress.

All services run in separate Docker containers.

## Start and Stop

From the project root:

```bash
make
```

This builds and starts the containers.

To stop the project:

```bash
make down
```

To check the running containers:

```bash
docker ps
```

You should see:

```text
nginx
wordpress
mariadb
```

## Website

The website is available at:

```text
https://ayhakimi.42.fr
```

The WordPress administration panel is available at:

```text
https://ayhakimi.42.fr/wp-admin
```

## Credentials

Sensitive credentials are stored as Docker Secrets in:

```text
secrets/
├── credentials.txt
├── db_password.txt
└── db_root_password.txt
```

General configuration is stored in:

```text
srcs/.env
```

Passwords and other sensitive information should not be committed publicly.

## Checking the Services

Check running containers:

```bash
docker ps
```

Check logs:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

Check the Docker network:

```bash
docker network inspect inception
```

Check persistent volumes:

```bash
docker volume ls
```

## Persistent Data

Project data is stored on the host in:

```text
/home/ayhakimi/data/mariadb
/home/ayhakimi/data/wordpress
```

This data persists when containers are stopped or recreated.
