FROM ubuntu:22.04

RUN apt update -y

RUN apt upgrade -y

RUN apt install simplestreams apache2 reprepro -y

# Maas-images setup

ENV KEYRING_FILE=/usr/share/keyrings/ubuntu-cloudimage-keyring.gpg

ENV IMAGE_SRC=https://images.maas.io/ephemeral-v3/stable

ENV IMAGE_DIR=/var/www/html/maas/images/ephemeral-v3/stable

RUN sstream-mirror --keyring=$KEYRING_FILE $IMAGE_SRC $IMAGE_DIR 'arch=amd64' 'release~(jammy)' --max=1 --progress

# Reprepro apt mirror setup

RUN mkdir -p /var/www/html/repos/apt/ubuntu/conf

COPY docker/distributions /var/www/html/repos/apt/ubuntu/conf/distributions

COPY docker/options /var/www/html/repos/apt/ubuntu/conf/options

ENV REPREPRO_BASE_DIR=/var/www/html/repos/apt/ubuntu

ENV PACKAGES="lldpd ipmitool freeipmi-tools python3-paramiko"

RUN mkdir -p /packages

RUN cd packages && apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests \
    --no-conflicts --no-breaks --no-enhances \
    --no-pre-depends ${PACKAGES} | grep "^\w") \
    && reprepro createsymlinks \
    && reprepro includedeb jammy /packages/*.deb \
    && rm -rf /packages \
    && apt-get autoclean \
    && apt-get autoremove

CMD ["apachectl", "-D", "FOREGROUND"]