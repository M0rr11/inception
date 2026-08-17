FROM debian:bookworm

# Install MariaDB server, no recommended extras, clean apt cache after
RUN apt-get update && \
    apt-get install -y --no-install-recommends mariadb-server && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/lib/mysql/*

# Copy our config override (binds to all interfaces, not just localhost)
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy the script that initializes the DB and starts the server
COPY tools/init_db.sh /usr/local/bin/init_db.sh
RUN chmod +x /usr/local/bin/init_db.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/init_db.sh"]