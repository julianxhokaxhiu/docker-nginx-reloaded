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
find $DATA_DIR -type d -exec chmod 775 {} \;
find $DATA_DIR -type f -exec chmod 664 {} \;

# Start supervisor
/usr/bin/supervisord -c /etc/supervisord.conf
