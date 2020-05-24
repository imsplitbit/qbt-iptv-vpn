# QBittorrent / IPTV-proxy over Openvpn

FROM ubuntu:18.04
LABEL maintainer=imsplitbit@gmail.com

ENV DEBIAN_FRONTEND noninteractive
ENV IPTV_VERSION 2.0.3

WORKDIR /opt

# Make directories
RUN mkdir -p /config/openvpn /config/iptv-vpn /config/qbittorrent

# Update, upgrade and install required packages
RUN apt update \
    && apt -y upgrade \
    && apt -y install \
    apt-transport-https \
    software-properties-common \
    apt-utils \
    openssl \
    wget \
    curl \
    gnupg \
    git \
    sed \
    openvpn \
    emacs-nox \
    curl \
    moreutils \
    net-tools \
    dos2unix \
    kmod \
    iptables \
    procps \
    ipcalc\
    grep \
    libcurl4 \
    liblttng-ust0 \
    libkrb5-3 \
    zlib1g \
    tzdata \
    python3 \
    python3-pip \
    dnsutils \
    unrar \
    unzip


# install qbittorrent ppa and packages
RUN add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable \
    && apt-get update \
    && apt-get install -y qbittorrent-nox


# apt cleanup
RUN apt-get clean \
    && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

# Install iptv-proxy
RUN curl -o iptv-proxy.deb -skSL "https://github.com/pierre-emmanuelJ/iptv-proxy/releases/download/v${IPTV_VERSION}/iptv-proxy_${IPTV_VERSION}_linux_amd64.deb" \
    && dpkg -i iptv-proxy.deb \
    && rm -f iptv-proxy.deb


VOLUME /config

ADD openvpn/ /etc/openvpn/
ADD iptables/ /etc/iptables/
ADD iptv-proxy/ /etc/iptv-proxy/
ADD qbittorrent/ /etc/qbittorrent/
ADD supervisor/ /etc/supervisor/

RUN chmod +x /etc/iptv-proxy/*.sh /etc/openvpn/*.sh /etc/qbittorrent/*.sh /etc/iptables/*.sh

CMD ["/bin/bash", "/etc/supervisor/start.sh"]