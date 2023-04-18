version: "3.8"

services:
  wordpress:
    image: arm64v8/wordpress
    container_name: wordpress
    restart: unless-stopped
    environment:
      WORDPRESS_DB_HOST: ${dbhost}:3306
      WORDPRESS_DB_USER: ${dbuser}
      WORDPRESS_DB_PASSWORD: ${dbpassword}
      WORDPRESS_DB_NAME: ${dbname}
      VIRTUAL_HOST: ${subdomain}.${domain}
      LETSENCRYPT_HOST: ${subdomain}.${domain}
      LETSENCRYPT_EMAIL: ${email}
    volumes:
      - ./data:/var/www/html
      - ./conf.d/php.ini:/usr/local/etc/php/conf.d/php.ini
    networks:
      - proxy

  phpmyadmin:
    image: arm64v8/phpmyadmin
    container_name: phpmyadmin
    restart: unless-stopped
    environment:
      PMA_HOST: ${dbhost}:3306
      PMA_USER: ${dbuser}
      PMA_PASSWORD: ${dbpassword}
      VIRTUAL_HOST: admin.${domain}
      LETSENCRYPT_HOST: admin.${domain}
      LETSENCRYPT_EMAIL: ${email}
    networks:
      - proxy

networks:
  proxy:
    external: true