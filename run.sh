#!/bin/bash

MY_PATH=$(dirname $(realpath $0))

. $MY_PATH/docker-name.conf

params="$(getopt -o fs: -l fg,src: --name "$O" -- $@)"
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
        $DOCKER_ARGS \
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

echoHelp()
{
    echo "run.sh [CMD] [OPTIONS]"
    echo "CMD: "
    echo "  stop    to stop container"
    echo "  rm      to remove container"
    echo "  stopRm  to stop and remove contaier"
    echo "  resolv  to modify resolv.conf file with ip address of dnsmasq container"
    echo "  help    to show this message"
    echo "  run     to start the container"
    echo "    [OPTIONS]:"
    echo "      -f | --fg   to run container on foreground (default is deamon run)"
    echo "      -s | --src  to give the dnsmasq folder link with /etc/dnsmasq on container"
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
    help)
        echoHelp
        ;;
    *)
        echo "Command not found"
        echoHelp
        ;;
esac   
