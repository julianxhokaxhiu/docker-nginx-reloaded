FROM alpine:edge
MAINTAINER Julian Xhokaxhiu <info at julianxhokaxhiu dot com>

# Environment variables
#######################

ENV DATA_DIR /srv/data

# Configurable environment variables
####################################

# Custom DNS where to forward your request, if not found inside the DNS Server.
# By default this will be forwarded to Google DNS for IPv4 and IPv6 requests.
# See https://doc.powerdns.com/md/recursor/settings/#forward-zones
ENV CUSTOM_DNS "8.8.8.8;8.8.4.4;[2001:4860:4860::8888];[2001:4860:4860::8844]"

# Change this cron rule to what fits best for you.
# Used only if ENABLE_ADBLOCK=true
# By Default runs twice a day: At 7:00 UTC and at 19:00 UTC
ENV CRONTAB_TIME '0 7,19 * * *'

# Create Volume entry points
############################

VOLUME $DATA_DIR

# Copy required files and fix permissions
#########################################

COPY src/* /root/

# Create missing directories
############################

RUN mkdir -p $DATA_DIR

# Set the work directory
########################

WORKDIR /root

# Fix permissions
#################

RUN chmod 0644 * \
    && chmod 0755 *.sh

# Install required packages
##############################

RUN apk --update add --no-cache \
    bash \
    curl \
    # Supervisor Daemon
    supervisor \
    # Nginx Server
    nginx

# Install development packages
##############################
RUN apk --update add --no-cache --virtual .build-deps \
    git

# Install the acme.sh client
############################

RUN curl https://get.acme.sh | sh

# Cleanup
#########

RUN find /usr/local \
      \( -type d -a -name test -o -name tests \) \
      -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
      -exec rm -rf '{}' + \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*

# Replace default configurations
################################
RUN rm /etc/supervisord.conf \
    && mv /root/supervisord.conf /etc

# Allow redirection of stdout to docker logs
############################################
RUN ln -sf /proc/1/fd/1 /var/log/docker.log

# Expose required ports
#######################

EXPOSE 53
EXPOSE 53/udp
EXPOSE 80
EXPOSE 443

# Change Shell
##############
SHELL ["/bin/bash", "-c"]

# Set the entry point to init.sh
###########################################

ENTRYPOINT /root/init.sh
