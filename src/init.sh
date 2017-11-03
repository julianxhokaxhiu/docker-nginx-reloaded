#!/bin/bash
#
# Init script
#
###########################################################

# Thanks to http://stackoverflow.com/a/10467453
function sedeasy {
  sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

# Fix permissions
find $NGINX_CERTS -type f -exec chmod 664 {} \;
find $NGINX_VHOSTD -type f -exec chmod 664 {} \;
find $NGINX_HTPASSWD -type f -exec chmod 664 {} \;

# Start supervisor
/usr/bin/supervisord -c /etc/supervisord.conf
