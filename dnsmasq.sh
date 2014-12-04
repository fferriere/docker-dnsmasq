#!/bin/bash

MY_PATH=$(dirname $(realpath $0))

. $MY_PATH/docker-name.conf

params="$(getopt -o lfs: -l fg,local,src: --name "$O" -- $@)"
eval set -- "$params"

SRC=$MY_PATH/dnsmasq
DOCKER_ARGS='-d'
CMD=''
USE_LOCALHOST=false
LOCAL_ADDR='127.0.0.1'

while true
do
    case "$1" in
        -f|--fg)
            DOCKER_ARGS='-ti --rm'
            shift
            ;;
        -s|--src)
            shift
            SRC="$1"
            shift
            ;;
        -l|--local)
            USE_LOCALHOST=true
            shift
            ;;
        --)
            shift
            break
            ;;
    esac
done

build()
{
    docker build -t $DOCKER_IMAGE_NAME $1 $MY_PATH/.
}

run()
{
    if [ ! -d $SRC ]; then
        echo "$SRC is not a directory"
        exit 1
    fi
    CONF_FILE="$SRC/resolv.dnsmasq.conf"
    DIST_FILE=$CONF_FILE'.dist'
    if [ ! -f $CONF_FILE ]; then
        if [ -f $DIST_FILE ]; then
            cp $DIST_FILE $CONF_FILE
        else
            echo "$CONF_FILE is missing"
            exit 1
        fi
    fi
    getCmd $1
    eval $CMD
}

getCmd()
{
    if [ true == $USE_LOCALHOST ]; then
        DOCKER_ARGS="$DOCKER_ARGS -p 53:53/udp"
    fi
    CMD="docker run \
        $DOCKER_ARGS \
        --name $DOCKER_CONTAINER_NAME \
        -v $SRC:/etc/dnsmasq \
        $DOCKER_IMAGE_NAME $1"
}

dryRun()
{
    getCmd $1
    echo $CMD
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
    if [ true == $USE_LOCALHOST ]; then
        IP_ADDRESS=$LOCAL_ADDR
    else
        IP_ADDRESS=$(docker inspect -f "{{.NetworkSettings.IPAddress}}" $DOCKER_CONTAINER_NAME)
    fi
    if [ $? -eq 0 ]; then
        echo "nameserver $IP_ADDRESS" > /etc/resolv.conf
    fi
}

reloadDnsmasq()
{
    if [ ! -d $SRC ]; then
        echo "$SRC is not a directory"
        exit 1
    fi
    if [ ! -w $SRC ]; then
        echo "$SRC is not writable"
        exit 1
    fi
    touch $SRC/reload
}

echoHelp()
{
    echo "run.sh [CMD] [OPTIONS]"
    echo "CMD: "
    echo "  build   to build container (you can use docker build options after --)"
    echo "  stop    to stop container"
    echo "  rm      to remove container"
    echo "  stop-rm  to stop and remove contaier"
    echo "  resolv  to modify resolv.conf file with ip address of dnsmasq container"
    echo "  help    to show this message"
    echo "  run     to start the container"
    echo "    [OPTIONS]:"
    echo "      -f | --fg   to run container on foreground (default is deamon run)"
    echo "      -s | --src  to give the dnsmasq folder link with /etc/dnsmasq on container"
    echo "  dry-run generate the docker run command and show it"
    echo "  reload  to reload the dnsmasq configuration"
    echo "    you can use -s | --src option with this command as with run command"
}

case "$1" in
    build)
        shift
        build "$@"
        ;;
    run)
        shift
        run "$@"
        ;;
    stop)
        stopContainer
        ;;
    rm)
        removeContainer
        ;;
    stop-rm)
        stopContainer
        removeContainer
        ;;
    resolv)
        updateResolv
        ;;
    reload)
        reloadDnsmasq
        ;;
    dry-run)
        shift
        dryRun "$@"
        ;;
    help)
        echoHelp
        ;;
    *)
        echo "Command not found"
        echoHelp
        ;;
esac   
