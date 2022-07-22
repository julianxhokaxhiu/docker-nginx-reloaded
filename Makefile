###############################################################################
# ENVIRONMENT CONFIGURATION
###############################################################################
MAKEFLAGS += --no-print-directory
SHELL=/bin/bash

# Use default as default goal when running 'make'
.PHONY: default
.DEFAULT_GOAL := default

###############################################################################
# GOAL PARAMETERS
###############################################################################

# iPerf3 CLI Arguments
IPERF3_ARGS ?= ""

# Container name
CONTAINER_NAME ?= "julianxhokaxhiu/docker-nginx-reloaded"

# Tag name
TAG_NAME ?= "latest"

###############################################################################
# GOALS ( safe defaults )
###############################################################################

default:
	@docker build -t $(CONTAINER_NAME):$(TAG_NAME) .

run:
	@docker run --rm=true -it -e "LE_ACME_ENABLE=0" $(CONTAINER_NAME):$(TAG_NAME)

clean:
	@docker rmi $(CONTAINER_NAME):$(TAG_NAME)
