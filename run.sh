#!/bin/bash

MY_PATH=$(dirname $(realpath $0))

. $MY_PATH/docker-name.conf

docker run -ti $DOCKER_IMAGE_NAME "$@"
