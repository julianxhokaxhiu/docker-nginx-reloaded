FROM alpine:edge
MAINTAINER Julian Xhokaxhiu <info at julianxhokaxhiu dot com>

# Environment variables
#######################

ENV NGINX_CERTS /etc/nginx/certs
ENV NGINX_VHOSTD /etc/nginx/vhost.d
ENV NGINX_HTPASSWD /etc/nginx/htpasswd

# Configurable environment variables
####################################

# Custom DNS where to forward your request, if not found inside the DNS Server.
# By default this will be forwarded to Google DNS for IPv4 and IPv6 requests.
# See https://doc.powerdns.com/md/recursor/settings/#forward-zones
ENV DNSALT1 '8.8.8.8'
ENV DNSALT2 '8.8.4.4'
ENV DNS6ALT1 '2001:4860:4860::8888'
ENV DNS6ALT2 '2001:4860:4860::8844'

# Change this cron rule to what fits best for you.
# Used only if ENABLE_ADBLOCK=true
# By Default runs twice a day: At 7:00 UTC and at 19:00 UTC
ENV CRONTAB_TIME '0 7,19 * * *'

# Create Volume entry points
############################

VOLUME $NGINX_CERTS
VOLUME $NGINX_VHOSTD
VOLUME $NGINX_HTPASSWD

# Copy required files and fix permissions
#########################################

COPY src/* /root/

# Create missing directories
############################

RUN mkdir -p $NGINX_CERTS \
    mkdir -p $NGINX_VHOSTD \
    mkdir -p $NGINX_HTPASSWD

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
    nginx \
    # NodeJS
    nodejs \
    # NPM
    nodejs-npm

# Install the acme.sh client
############################

RUN curl https://get.acme.sh | sh

# Install dynsdjs + docker plugin
#################################

RUN npm install --only=prod --no-optional -g dynsdjs \
    && npm install --only=prod --no-optional -g dynsdjs-plugin-docker

# Cleanup
#########

RUN find /usr/local \
      \( -type d -a -name test -o -name tests \) \
      -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
      -exec rm -rf '{}' + \
    && rm -rf /var/cache/apk/*

# Replace default configurations
################################
RUN rm /etc/supervisord.conf \
    && mv /root/supervisord.conf /etc \
    && cp -Rf /root/nginx/* /etc/nginx \
    && rm -Rf /root/nginx

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
