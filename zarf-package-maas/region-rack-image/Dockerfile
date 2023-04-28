# Run with Docker standalone using:
# docker build . -t maas
# docker run -it --cgroupns=host --tmpfs /tmp --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup -p 5240:5240 maas

FROM ubuntu:22.04

RUN apt update -qq && \
    apt install -y software-properties-common

RUN apt-add-repository -y ppa:maas/3.3-next 
ENV DEBIAN_FRONTEND=noninteractive

RUN apt install -y --no-install-recommends tzdata && \
    apt install maas -y

# Install: dependencies, clean: apt cache, remove dir: cache, man, doc, change mod time of cache dir.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       software-properties-common \
       rsyslog systemd systemd-cron sudo \
    && apt-get clean \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && rm -rf /var/lib/apt/lists/* \
    && touch -d "2 hours ago" /var/lib/apt/lists
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

RUN rm -f /lib/systemd/system/systemd*udev* \
  && rm -f /lib/systemd/system/getty.target

COPY addmaasuser.sh /bin/addmaasuser.sh
COPY runonce.service /usr/lib/systemd/system/runonce.service

RUN chmod +x /bin/addmaasuser.sh \
  && systemctl enable runonce.service

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/lib/systemd/systemd"]
