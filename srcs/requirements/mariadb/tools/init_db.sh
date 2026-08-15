#!/bin/bash
set -e

# Only initialize on first run (check if the DB directory is empty)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # Start MariaDB temporarily in the background JUST for setup
    mysqld_safe --datadir=/var/lib/mysql --skip-networking &
    SETUP_PID=$!

    # Wait until it's actually ready to accept commands
    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done

    # Read secrets (mounted as files, not env vars, for security)
    DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
    DB_PASSWORD=$(cat /run/secrets/db_password)

    mariadb -u root <<-EOSQL
        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
        CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
        FLUSH PRIVILEGES;
EOSQL

    # Stop the temporary background instance cleanly
    mysqladmin shutdown -u root -p"${DB_ROOT_PASSWORD}"
    wait $SETUP_PID
fi

# Hand off to the REAL foreground process — this becomes PID 1
exec mysqld_safe --datadir=/var/lib/mysql