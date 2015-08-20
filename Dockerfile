FROM fferriere/base

MAINTAINER ferriere.florian@gmail.com

RUN apt-get install -y dnsmasq inotify-tools

RUN echo "bind-interfaces\nconf-dir=/etc/dnsmasq/conf.d\nresolv-file=/etc/dnsmasq/resolv.dnsmasq.conf\nuser=root" >> /etc/dnsmasq.conf

ADD files/dnsmasq.sh /usr/local/bin/dnsmasq.sh
ADD files/entrypoint.sh /usr/local/bin/entrypoint.sh

VOLUME ['/etc/dnsmasq']

CMD /usr/local/bin/entrypoint.sh

EXPOSE 53
