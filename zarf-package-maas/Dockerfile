FROM ubuntu:22.04

RUN apt update -y

RUN apt upgrade -y

RUN apt install simplestreams apache2 -y

ENV KEYRING_FILE=/usr/share/keyrings/ubuntu-cloudimage-keyring.gpg

ENV IMAGE_SRC=https://images.maas.io/ephemeral-v3/stable

ENV IMAGE_DIR=/var/www/html/maas/images/ephemeral-v3/stable

RUN sstream-mirror --keyring=$KEYRING_FILE $IMAGE_SRC $IMAGE_DIR 'arch=amd64' 'release~(jammy)' --max=1 --progress

CMD ["apachectl", "-D", "FOREGROUND"]