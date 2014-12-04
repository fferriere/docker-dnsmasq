#!/bin/bash

MY_PATH=$(dirname $(realpath $0))

$MY_PATH/dnsmasq.sh -l run
sudo $MY_PATH/dnsmasq.sh resolv
