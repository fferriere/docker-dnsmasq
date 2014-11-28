#!/bin/bash

MY_PATH=$(dirname $(realpath $0))

. $MY_PATH/docker-name.conf

params="$(getopt -o fs: -l fg,src: --name "$O" -- $@)"
echo $params
eval set -- "$params"

SRC=$MY_PATH/dnsmasq
DOCKER_ARGS='-d'

while true
do
    case "$1" in
        -f|--fg)
            DOCKER_ARGS='-ti'
            shift
            ;;
        -s|--src)
            shift
            SRC="$1"
            shift
            ;;
        --)
            shift
            break
            ;;
    esac
done

run()
{
    docker run \
        $DOCKER_ARGS
        --name $DOCKER_CONTAINER_NAME \
        -v $SRC:/etc/dnsmasq \
        $DOCKER_IMAGE_NAME "$@"
}

stopContainer()
{
    docker stop -t 0 $DOCKER_CONTAINER_NAME
}

removeContainer()
{
    docker rm $DOCKER_CONTAINER_NAME
}

updateResolv()
{
    IP_ADDRESS=$(docker inspect -f "{{.NetworkSettings.IPAddress}}" $DOCKER_CONTAINER_NAME)
    if [ $? -eq 0 ]; then
        echo "nameserver $IP_ADDRESS" > /etc/resolv.conf
    fi
}

case "$1" in
    run)
        run
        ;;
    stop)
        stopContainer
        ;;
    rm)
        removeContainer
        ;;
    stopRm)
        stopContainer
        removeContainer
        ;;
    resolv)
        updateResolv
        ;;
esac   
