docker-dnsmasq
==============

This project permit to use dnsmasq under a docker container.
The dnsmasq configuration could be update after container.

Installation
------------

To install this container clone the repository :

Copy `docker-name.conf.dist` to `docker-name.conf`

Edit `docker-name.conf`

Run `dnsmasq.sh build` to build container

You can edit dnsmasq config after run container. You do run `dnsmasq.sh reload` or `touch path_dnsmasq/reload` file. By default `path_dnsmasq` is `dnsmasq` folder of this project. You can change it with `-s|--src option` of `dnsmasq.sh`

For systemd user it's possible to run `sudo dnsmasq.sh install`. Run `sudo systemctl enable docker-dnsmasq` for run container at boot.

Use
---

The `dnsmask.sh` script permit to run,stop,... container or reload configuration. Read the `--help` content to use the script.

Thanks
------

Thanks to creator of dnsmasq and to Pascal Martin (@pmartin (on github) and @pascal_martin (on twitter)) with his [presentation](http://blog.pascal-martin.fr/public/slides-tea-dnsmasq/)