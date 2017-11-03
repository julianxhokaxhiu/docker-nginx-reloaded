#!/bin/bash

CONTAINER_NAME=$1
CONTAINER_DOMAIN=$2

# If CONTAINER_DOMAIN is CSV, we split by comma, in order to get an array
IFS=, read -ra CONTAINER_DOMAINS <<< "$CONTAINER_DOMAIN"

# Generate SSL certificates
for key in "${!CONTAINER_DOMAINS[@]}"; do
  DOMAIN=$CONTAINER_DOMAINS[$key]

  # If it is a valid FQDN then process for SSL generation
  if [[ ! -z `echo $DOMAIN | grep -P '(?=^.{1,254}$)(^(?>(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)'` ]]; then
    # Domain may be declared with a port, if so, get only the domain value
    if [[ $DOMAIN == *":"* ]]; then
      IFS=, read -ra TMP <<< "$DOMAIN"
      DOMAIN=$TMP[0]
    fi

    # Generate the SSL certificate
    /root/.acme.sh/acme.sh \
      --issue \
      -d $DOMAIN \
      -w /var/www/localhost/htdocs

    # Install SSL certificate
    /root/.acme.sh/acme.sh \
      --install-cert \
      -d $DOMAIN \
      --key-file /etc/nginx/certs/$DOMAIN.key \
      --fullchain-file /etc/nginx/certs/$DOMAIN.crt
  fi
done

# Reload nginx service
nginx -s reload
