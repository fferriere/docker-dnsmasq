FROM debian:wheezy

ENV DEBIAN_FRONTEND
ENV TERM linux

RUN apt-get update -y && \
    apt-get install -y locales net-tools procps


