FROM ubuntu:bionic
MAINTAINER carrene <info@carrene.com>
COPY .ssh /root/.ssh
# place .ssh contains private and public key for default carrene user
# and known-hosts with git server host keys beside Dockerfile in the same dir
# to be copied inside docker image
ENV TZ=Asia/Tehran DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y \
  && ln -sf /usr/share/zoneinfo/$TZ /etc/localtime \
  && apt-get install -y apt-utils locales tzdata \
  && locale-gen en_US.UTF-8 \
  && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8 \
  && apt-get install -y apt-utils libass-dev libpq-dev postgresql \
  build-essential curl redis-server redis-tools python3-pip python3-dev git \
  && pip3 install -U pip setuptools wheel virtualenv \
  && apt-get autoremove -y && apt-get upgrade -y && chmod 755 /root/.ssh \
  && chmod 644 /root/.ssh/* && chmod 600 /root/.ssh/id_rsa \ 
  && rm -rf /var/lib/apt/lists/* && service postgresql start \
  && su postgres -c \
  "psql -U postgres -c \"ALTER USER postgres PASSWORD 'postgres';\"" \
  && echo "listen_addresses='*'" >> /etc/postgresql/10/main/postgresql.conf \
  && echo "bind 127.0.0.1" >> /etc/redis/redis.conf
CMD service postgresql start && service redis-server start && /bin/bash

