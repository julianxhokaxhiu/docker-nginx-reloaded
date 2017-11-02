#!/bin/bash

CONTAINER_NAME=$1
CONTAINER_DOMAIN=$2

# If CONTAINER_DOMAIN is CSV, we split by comma, in order to get an array
IFS=, read -ra CONTAINER_DOMAINS <<< "$CONTAINER_DOMAIN"

# Generate SSL certificates
for key in "${!CONTAINER_DOMAINS[@]}"; do
  DOMAIN=$CONTAINER_DOMAINS[$key]

  # Domain may be declared with a port, if so, get only the domain value
  if [[ $DOMAIN == *":"* ]]; then
    IFS=, read -ra TMP <<< "$DOMAIN"
    DOMAIN=$TMP[0]
  fi

  # Generate the SSL certificate
  acme.sh \
    --issue \
    -d $DOMAIN \
    -w /var/www/localhost/htdocs

  # Install SSL certificate
  acme.sh \
    --install-cert \
    -d $DOMAIN \
    --key-file /etc/nginx/certs/$DOMAIN.key \
    --fullchain-file /etc/nginx/certs/$DOMAIN.crt
done

# Reload nginx service
nginx -s reload
