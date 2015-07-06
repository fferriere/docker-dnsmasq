#!/bin/bash

MY_PATH=$(dirname $(realpath $0))

. $MY_PATH/docker-name.conf

params="$(getopt -o afls: -l anonymous,fg,local,src: --name "$O" -- $@)"
eval set -- "$params"

SRC=$MY_PATH/dnsmasq
DOCKER_ARGS='-d'
CMD=''
USE_LOCALHOST=false
LOCAL_ADDR='127.0.0.1'
NAMED_CONTAINER=true

while true
do
    case "$1" in
        -f|--fg)
            DOCKER_ARGS='--rm'
            shift
            ;;
        -a|--anonymous)
            NAMED_CONTAINER=false
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

errEcho()
{
    >&2 echo "$@"
}

build()
{
    docker build -t $DOCKER_IMAGE_NAME $1 $MY_PATH/.
}

checkDirExists()
{
    if [ ! -d $1 ]; then
        errEcho "Source directory '$1' is not a good directory"
        exit 1
    fi
}

checkDirWritable()
{
    if [ ! -w $1 ]; then
        errEcho "Source directory '$1' is not writable"
        exit 2
    fi
}

run()
{
    checkDirExists $SRC
    CONF_FILE="$SRC/resolv.dnsmasq.conf"
    DIST_FILE=$CONF_FILE'.dist'
    if [ ! -f $CONF_FILE ]; then
        if [ -f $DIST_FILE ]; then
            cp $DIST_FILE $CONF_FILE
        else
            errEcho "$CONF_FILE is missing"
            exit 3
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
    NAME_ARG=''
    if [ true == $NAMED_CONTAINER ]; then
        NAME_ARG="--name $DOCKER_CONTAINER_NAME"
    fi
    CMD="docker run \
        $DOCKER_ARGS \
        $NAME_ARG \
        -v $SRC:/etc/dnsmasq \
        $DOCKER_IMAGE_NAME $1"
}

dryRun()
{
    getCmd $1
    echo $CMD
}

getNbContainer()
{
    nbContainer=$(docker ps -a | grep $DOCKER_CONTAINER_NAME | wc -l)
}

stopContainer()
{
    getNbContainer
    if [ "$nbContainer" -gt 0 ]; then
        docker stop -t 0 $DOCKER_CONTAINER_NAME
    fi
}

removeContainer()
{
    getNbContainer
    if [ "$nbContainer" -gt 0 ]; then
        docker rm $DOCKER_CONTAINER_NAME
    fi
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
    checkDirExists $SRC
    checkDirWritable $SRC
    touch $SRC/reload
}

install()
{
    build
    ln -nfs $MY_PATH/scripts/ /usr/local/bin/docker-dnsmasq
    cp $MY_PATH/files/docker-dnsmasq.service.systemd /usr/lib/systemd/system/docker-dnsmasq.service
}

uninstall()
{
    rm /usr/lib/systemd/system/docker-dnsmasq.service
    rm /usr/local/bin/docker-dnsmasq
}

echoHelp()
{
    echo "run.sh [CMD] [OPTIONS]"
    echo "CMD: "
    echo "  build   to build container (you can use docker build options after --)"
    echo "  stop    to stop container"
    echo "  rm      to remove container"
    echo "  stop-rm to stop and remove contaier"
    echo "  resolv  to modify resolv.conf file with ip address of dnsmasq container"
    echo "  help    to show this message"
    echo "  install to install container at boot with systemd, you must to run this command with root or with sudo"
    echo "  uninstall to uninstall container at boot, you must to run this command with root or sudo"
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
    install)
        install
        ;;
    uninstall)
        uninstall
        ;;
    help)
        echoHelp
        ;;
    *)
        echo "Command not found"
        echoHelp
        ;;
esac   
