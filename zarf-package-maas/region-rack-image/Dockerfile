FROM ubuntu:22.04

RUN apt update

RUN apt install -y software-properties-common

RUN apt-add-repository -y ppa:maas/3.3-next

RUN apt update

RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends tzdata

RUN apt install maas-rack-controller maas-region-api dbconfig-pgsql -y
RUN apt download maas-region-controller
RUN dpkg --install --ignore-depends=postgresql maas-region-controller*.deb
RUN apt install python3-django-maas -y

# FROM ubuntu:22.04 as maas-unpacker

# RUN apt update

# RUN apt install -y  squashfs-tools

# COPY maas.snap /tmp/maas.snap

# RUN mkdir -p /maas

# RUN unsquashfs /tmp/maas.snap

# FROM ubuntu:22.04

# COPY --from=maas-unpacker /squashfs-root/ /

# # software-properties-common

# # RUN apt-add-repository -y ppa:maas/3.3-next

# # RUN apt update

# # RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends tzdata

# # RUN apt-get install -y maas postgresql-