FROM debian:wheezy

ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

RUN apt-get update -y && \
    apt-get install -y locales net-tools procps dnsmasq rsyslog cron

RUN echo "Europe/Paris" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    sed -i "s/^# fr_FR/fr_FR/" /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=fr_FR.UTF-8

RUN echo "bind-interfaces\nconf-dir=/etc/dnsmasq/conf.d\nresolv-file=/etc/resolv.dnsmasq.conf\nuser=root" >> /etc/dnsmasq.conf

ADD files/crontab /etc/crontab
ADD files/dnsmasq.sh /usr/local/bin/dnsmasq.sh
ADD files/resolv.dnsmasq.conf /etc/resolv.dnsmasq.conf
ADD files/entrypoint.sh /usr/local/bin/entrypoint.sh

VOLUME ['/etc/dnsmasq']

CMD /usr/local/bin/entrypoint.sh

EXPOSE 53
