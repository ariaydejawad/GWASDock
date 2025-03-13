FROM ubuntu:24.04@sha256:72297848456d5d37d1262630108ab308d3e9ec7ed1c3286a32fe09856619a782 AS build

WORKDIR /workspace/program/plink

RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        g++ \
        gcc \
        libblas-dev \
        libatlas-base-dev \
        liblapack-dev \
        make

ADD https://github.com/chrchang/plink-ng.git#v2.0.0-a.6.9 ./codebase

RUN cd codebase/1.9 \
        && ln -s /usr/bin/sha1sum /usr/bin/shasum \
        && ./plink_first_compile \
        && make all \
        && make install DESTDIR=/

FROM ubuntu:24.04@sha256:72297848456d5d37d1262630108ab308d3e9ec7ed1c3286a32fe09856619a782 AS production

WORKDIR /workspace/plink-production

RUN apt-get update && apt-get install -y --no-install-recommends \
        libblas3 \
        libatlas3-base \
        liblapack3

COPY --from=build /usr/local/bin/plink /usr/local/bin/plink
