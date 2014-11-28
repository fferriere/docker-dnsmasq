#!/bin/bash

rsyslogd
cron
/etc/init.d/dnsmasq start
touch /var/log/cron.log
tail -f /var/log/syslog /var/log/cron.log
