#!/bin/bash

CONTAINER_NAME=$1
CONTAINER_DOMAIN=$2
CONTAINER_ISVHOST=$3

# acme.sh multi-domain holder
ACMESH_DOMAINS=""

# If CONTAINER_DOMAIN is CSV, we split by comma, in order to get an array
IFS=, read -ra CONTAINER_DOMAINS <<< "$CONTAINER_DOMAIN"

# Generate list of domains
for key in "${!CONTAINER_DOMAINS[@]}"; do
  DOMAIN=${CONTAINER_DOMAINS[$key]}

  # If the container contains a VIRTUAL_HOST entry, then generate the SSL
  if [[ $CONTAINER_ISVHOST == 1 ]]; then
    # Domain may be declared with a port, if so, get only the domain value
    if [[ $DOMAIN == *":"* ]]; then
      IFS=, read -ra TMP <<< "$DOMAIN"
      DOMAIN=${TMP[0]}
    fi

    if [ -z "$ACMESH_DOMAINS" ]; then
      ACMESH_DOMAINS="$DOMAIN"
    else
      ACMESH_DOMAINS="${ACMESH_DOMAINS} -d $DOMAIN"
    fi
  fi
done

# Generate the SSL certificate
/root/.acme.sh/acme.sh \
  --issue \
  --keylength ec-384 \
  -d $ACMESH_DOMAINS \
  -w /var/www/localhost/htdocs

# Successful flag for the issue command
ACMESH_SUCCESSFUL=$?

# Install SSL certificates
for key in "${!CONTAINER_DOMAINS[@]}"; do
  DOMAIN=${CONTAINER_DOMAINS[$key]}

  # If the container contains a VIRTUAL_HOST entry, then generate the SSL
  if [[ $CONTAINER_ISVHOST == 1 ]]; then
    # Domain may be declared with a port, if so, get only the domain value
    if [[ $DOMAIN == *":"* ]]; then
      IFS=, read -ra TMP <<< "$DOMAIN"
      DOMAIN=${TMP[0]}
    fi

    # ACMESH_SUCCESSFUL can be 0 ( successful ) or 2 ( no need to renew )
    if [ $ACMESH_SUCCESSFUL -eq 0 ] || [ $ACMESH_SUCCESSFUL -eq 2 ]; then
      # Install SSL certificate
      /root/.acme.sh/acme.sh \
        --install-cert \
        -d $DOMAIN \
        --key-file /etc/nginx/certs/$DOMAIN.key \
        --fullchain-file /etc/nginx/certs/$DOMAIN.crt

      # Copy OCSP chain file
      cp $LE_CONFIG_HOME/${DOMAIN}_ecc/ca.cer /etc/nginx/certs/$DOMAIN.chain.pem
    fi
  fi
done
