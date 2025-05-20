# Use the official Ubuntu latest image as base
FROM ubuntu:latest

# Install all required dependencies
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        flex \
        bison \
        libssl-dev \
        libelf-dev \
        bc \
        python3 \
        kmod \
        cpio \
        pahole \
        wget \
        unzip \
        findutils \
        && \
    rm -rf /var/lib/apt/lists/*

# Download and prepare WSL kernel source
RUN wget https://github.com/microsoft/WSL2-Linux-Kernel/archive/refs/tags/linux-msft-wsl-5.15.167.4.zip && \
    unzip linux-msft-wsl-5.15.167.4.zip && \
    rm linux-msft-wsl-5.15.167.4.zip && \
    mv WSL2-Linux-Kernel-linux-msft-wsl-5.15.167.4 /wsl-kernel

# Configure the kernel
WORKDIR /wsl-kernel
RUN make KCONFIG_CONFIG=Microsoft/config-wsl olddefconfig

# Build the kernel (this step is optional for module building, but included for completeness)
RUN make -j$(nproc) KCONFIG_CONFIG=Microsoft/config-wsl

# Create a helper script for building modules
RUN echo '#!/bin/bash\n\
if [ -z "$1" ]; then\n\
    echo "Usage: docker run -v \$(pwd):/module <image> /module"\n\
    exit 1\n\
fi\n\
\n\
cd /wsl-kernel\n\
make M=$1 modules' > /usr/local/bin/build-module && \
    chmod +x /usr/local/bin/build-module

WORKDIR /
ENTRYPOINT ["/usr/local/bin/build-module"]
