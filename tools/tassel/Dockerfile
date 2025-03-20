FROM ubuntu:24.04@sha256:72297848456d5d37d1262630108ab308d3e9ec7ed1c3286a32fe09856619a782 AS production

WORKDIR /workspace/program/tassel

RUN apt-get update && apt-get install -y --no-install-recommends \
        openjdk-8-jre-headless

ADD https://bitbucket.org/tasseladmin/tassel-5-standalone.git#V5.2.95 ./production
