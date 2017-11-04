#!/bin/bash

CONTAINER_ISVHOST=$3

# If the container contains a VIRTUAL_HOST entry, then reload nginx config
if [[ $CONTAINER_ISVHOST == 1 ]]; then
  # Reload nginx service
  nginx -s reload
fi
