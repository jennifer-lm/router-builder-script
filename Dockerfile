FROM debian:stable-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && apt install -y \
    build-essential clang flex bison g++ gawk gcc-multilib g++-multilib \
    gettext git libncurses5-dev libssl-dev python3 python3-distutils rsync unzip zlib1g-dev \
    file wget curl time sudo

# Clone ImmortalWrt repository and checkout specified branch
RUN git clone https://github.com/immortalwrt/immortalwrt.git /openwrt && \
    cd /openwrt && \
    git checkout 24.10.0

# Install additional packages
RUN cd /openwrt/package && \
    git clone https://github.com/jerrykuku/luci-theme-argon.git && \
    git clone https://github.com/jerrykuku/luci-app-argon-config.git

# Update and install feeds
RUN cd /openwrt && \
    ./scripts/feeds update -a && \
    ./scripts/feeds install -a

# Copy configuration file
COPY /r3p-config/.config /openwrt/.config

# Set working directory
WORKDIR /openwrt

# Build firmware
RUN make defconfig && make -j$(nproc) V=s

# Copy firmware to output directory
RUN mkdir -p /output && \
    cp bin/targets/ramips/mt7621/*.bin /output/

# Define output volume
VOLUME [ "/output" ]
