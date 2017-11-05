#!/bin/bash
#
# Init script
#
###########################################################

# Thanks to http://stackoverflow.com/a/10467453
function sedeasy {
  sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

# Generate Self-Signed HTTPS certificate as default
openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/nginx/certs/default.key \
  -out /etc/nginx/certs/default.crt \
  -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=localhost"

# Generate dhparam only if does not exist, as it takes too much time during startup
if [ ! -f /etc/nginx/certs/dhparam.pem ]; then
  openssl dhparam \
    -out /etc/nginx/certs/dhparam.pem \
    2048
fi

# Fix permissions
find $NGINX_CERTS -type f -exec chmod 664 {} \;
find $NGINX_VHOSTD -type f -exec chmod 664 {} \;
find $NGINX_HTPASSWD -type f -exec chmod 664 {} \;

# Start supervisor
/usr/bin/supervisord -c /etc/supervisord.conf
