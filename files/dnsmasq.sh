#!/bin/bash

if [ -f /etc/dnsmasq/reload ]; then
	/etc/init.d/dnsmasq force-reload
	rm /etc/dnsmasq/reload
fi