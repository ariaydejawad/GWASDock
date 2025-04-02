FROM ubuntu:24.04@sha256:72297848456d5d37d1262630108ab308d3e9ec7ed1c3286a32fe09856619a782 AS production

WORKDIR /app/workspace/gapit

ADD scripts ./scripts

RUN apt-get update && apt-get install -y --no-install-recommends \
	automake \
	cmake \
	curl \
	g++ \
	gcc \
	gfortran \
	libblas-dev \
	libcurl4-openssl-dev \
	libfontconfig1-dev \
	libfreetype6-dev \
	libfribidi-dev \
	libgit2-dev \
	libharfbuzz-dev \
	liblapack-dev \
	libjpeg-dev \
	libpng-dev \
	libssl-dev \
	libtiff5-dev \
	libxml2-dev \
	make \
	r-base \
	zlib1g

RUN cd scripts/install-scripts \
	&& Rscript install_gapit.R
