#!/bin/bash

CONTAINER_NAME=$1
CONTAINER_DOMAIN=$2
CONTAINER_ISVHOST=$3

# If CONTAINER_DOMAIN is CSV, we split by comma, in order to get an array
IFS=, read -ra CONTAINER_DOMAINS <<< "$CONTAINER_DOMAIN"

# Generate SSL certificates
for key in "${!CONTAINER_DOMAINS[@]}"; do
  DOMAIN=${CONTAINER_DOMAINS[$key]}

  # If the container contains a VIRTUAL_HOST entry, then generate the SSL
  if [[ $CONTAINER_ISVHOST == 1 ]]; then
    # Domain may be declared with a port, if so, get only the domain value
    if [[ $DOMAIN == *":"* ]]; then
      IFS=, read -ra TMP <<< "$DOMAIN"
      DOMAIN=${TMP[0]}
    fi

    # Generate the SSL certificate
    /root/.acme.sh/acme.sh \
      --issue \
      -d $DOMAIN \
      -w /var/www/localhost/htdocs

    if [ $? -eq 0 ]; then
      # Install SSL certificate
      /root/.acme.sh/acme.sh \
        --install-cert \
        -d $DOMAIN \
        --key-file /etc/nginx/certs/$DOMAIN.key \
        --fullchain-file /etc/nginx/certs/$DOMAIN.crt

      # Copy OCSP chain file
      cp $LE_CONFIG_HOME/$DOMAIN/ca.cer /etc/nginx/certs/$DOMAIN.chain.pem
    fi
  fi
done
