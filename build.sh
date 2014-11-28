#!/bin/bash

MY_PATH=$(dirname $(realpath $0))

. $MY_PATH/docker-name.conf

docker build -t $DOCKER_IMAGE_NAME "$@" $MY_PATH/.
