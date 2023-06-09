FROM registry.hub.docker.com/library/ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt install --yes make curl p7zip-full xorriso gdisk parted udev
RUN passwd -d root
RUN apt clean