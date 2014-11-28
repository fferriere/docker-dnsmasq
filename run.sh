#!/bin/bash

MY_PATH=$(dirname $(realpath $0))

. $MY_PATH/docker-name.conf

SRC=$MY_PATH/dnsmasq

docker run -v $SRC:/etc/dnsmasq $DOCKER_IMAGE_NAME "$@"
