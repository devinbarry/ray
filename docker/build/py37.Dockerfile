ARG PYTHON_VERSION=3.7.6-buster

FROM python:${PYTHON_VERSION}

# Install packages needed for bazel and build
RUN apt-get update && apt-get -y install curl git gnupg2

# Install bazel
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | apt-key add - \
    && echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list \
    && apt-get update \
    && apt-get -y install bazel

WORKDIR /ray

ARG GEMFURY_TOKEN
ENV PYTHONUNBUFFERED 1

# Upgrade to latest pip
RUN pip install --upgrade pip

# Build Ray
RUN git clone https://github.com/devinbarry/ray.git \
    && cd ray \
    && git checkout develop \
    && cd python \
    && python setup.py bdist_wheel

# Push build up to Gemfury
RUN find ray/python/dist -mindepth 1 -maxdepth 1 -type f -print0 | xargs -0I{} curl -sSL -F package=@{} https://${GEMFURY_TOKEN}@push.fury.io/pythonista/
