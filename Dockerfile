# Dockerfile to build CodeQL container
# Sample build command:
# docker build --rm -t btnguyen2k/codeql-container-all -f Dockerfile .

FROM ubuntu:22.04 AS codeql_base
LABEL maintainer="btnguyen2k"

# tzdata install needs to be non-interactive
ENV DEBIAN_FRONTEND=noninteractive

ARG USERNAME=codeql
ENV CODEQL_HOME /usr/local/codeql-home

# create user, install/update basics and python
RUN adduser --home ${CODEQL_HOME} ${USERNAME} && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        nodejs \
        vim \
        curl \
        wget \
        git \
        git-lfs \
        build-essential \
        unzip \
        apt-transport-https \
        python3.10 \
        python3-venv \
        python3-pip \
        python3-setuptools \
        python3-dev \
        python-is-python3 \
        gnupg \
        g++ \
        make \
        gcc \
        apt-utils \
        rsync \
        file \
        dos2unix \
        gettext && \
        apt-get clean

# Clean up
RUN apt autoremove

