ARG PYTHON_VERSION=3.7.6-buster

FROM python:${PYTHON_VERSION} as builder

RUN apt-get update && apt-get -y install curl git gnupg2

RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | apt-key add - \
    && echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list \
    && apt-get update \
    && apt-get -y install bazel

WORKDIR /ray

ENV PYTHONUNBUFFERED 1

# Upgrade to latest pip
RUN pip install --upgrade pip

RUN git clone https://github.com/devinbarry/ray.git \
    && cd ray/python \
    && python setup.py bdist bdist_wheel
