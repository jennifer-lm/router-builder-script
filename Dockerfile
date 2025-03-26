FROM ubuntu:latest

# Install required dependencies
RUN apt update && apt install -y \
    build-essential clang flex bison g++ gawk gcc-multilib g++-multilib \
    gettext git libncurses5-dev libssl-dev python3 python3-venv python3-pip rsync unzip zlib1g-dev \
    file wget curl time sudo \
    && pip install setuptools \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Clone OpenWrt source code
RUN git clone --depth=1 --branch v24.10.0 https://github.com/immortalwrt/immortalwrt.git openwrt

# Add custom packages
RUN cd openwrt/package && \
    git clone https://github.com/jerrykuku/luci-theme-argon.git && \
    git clone https://github.com/jerrykuku/luci-app-argon-config.git

# Install feeds
RUN cd openwrt && \
    ./scripts/feeds update -a && \
    ./scripts/feeds install -a

# Generate default configuration
RUN cd openwrt && make defconfig

# Build OpenWrt firmware
RUN cd openwrt && make -j$(nproc) V=s
