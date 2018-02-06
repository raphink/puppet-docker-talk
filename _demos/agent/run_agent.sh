#!/bin/sh

NAME="$1"
TAG="${2:-latest}"
MASTER_IP="172.21.5.180"

docker run -d --name "puppet-agent-${NAME}" --hostname "${NAME}.c2c" \
              --add-host "master.c2c:${MASTER_IP}" \
              "puppet-agent:${TAG}"

