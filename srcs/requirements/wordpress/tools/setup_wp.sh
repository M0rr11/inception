#!/bin/bash
set -e

WP_PATH="/var/www/wordpress"

# Wait for MariaDB to actually be reachable before doing anything —
# containers start roughly together, DB might not be ready yet
until mariadb -h mariadb -u"${MYSQL_USER}" -p"$(cat /run/secrets/db_password)" -e "SELECT 1;" >/dev/null 2>&1; do
    echo "Waiting for MariaDB..."
    sleep 2
done

if [ ! -f "${WP_PATH}/wp-config.php" ]; then
    echo "Setting up WordPress..."

    # Download WordPress core files if not already present
    if [ ! -f "${WP_PATH}/wp-load.php" ]; then
        wp core download --path="${WP_PATH}" --allow-root
    fi

    DB_PASSWORD=$(cat /run/secrets/db_password)
    WP_ADMIN_PASSWORD=$(cat /run/secrets/credentials | grep ADMIN_PASSWORD | cut -d '=' -f2)
    WP_USER_PASSWORD=$(cat /run/secrets/credentials | grep USER_PASSWORD | cut -d '=' -f2)
    wp config create \
        --path="${WP_PATH}" \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost=mariadb \
        --allow-root

    wp core install \
        --path="${WP_PATH}" \
        --url="${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root

    wp user create \
        "${WP_SECOND_USER}" "${WP_SECOND_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --path="${WP_PATH}" \
        --allow-root

    chown -R www-data:www-data "${WP_PATH}"
fi

# Hand off to php-fpm in the foreground as PID 1
exec php-fpm8.2 -F