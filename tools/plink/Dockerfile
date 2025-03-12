FROM ubuntu:24.04@sha256:72297848456d5d37d1262630108ab308d3e9ec7ed1c3286a32fe09856619a782 AS build

WORKDIR /workspace/program/plink

RUN apt-get update && apt-get install -y --no-install-recommends \
        make \
        gcc
