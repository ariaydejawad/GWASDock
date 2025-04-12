FROM ubuntu:24.04@sha256:72297848456d5d37d1262630108ab308d3e9ec7ed1c3286a32fe09856619a782 AS build

WORKDIR /workspace/program/gcta

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        cmake \
        g++-12 \
        gcc-12 \
        gfortran-12 \
        libgsl-dev \
        libspectra-dev \
        libsqlite3-dev \
        libzstd-dev \
        make \
        wget \
        zlib1g-dev

RUN ln -s /usr/bin/g++-12 /usr/bin/g++ \
        && ln -s /usr/bin/gcc-12 /usr/bin/gcc \
        && ln -s /usr/bin/gfortran-12 /usr/bin/gfortran

RUN mkdir -p dependencies \
        && cd dependencies \
        && wget https://archives.boost.io/release/1.82.0/source/boost_1_82_0.tar.gz \
        && tar -xzvf boost_1_82_0.tar.gz

RUN cd dependencies/boost_1_82_0 \
        && ./bootstrap.sh \
        && ./b2 \
        && ./b2 headers \
        && ./b2 install --prefix="/usr/include/boost"

ADD https://github.com/OpenMathLib/OpenBLAS.git#v0.3.15 ./dependencies/openblas

RUN cd dependencies/openblas \
        && make \
        && make install PREFIX="/usr/include/openblas"

ADD https://gitlab.com/libeigen/eigen.git#3.3.7 ./dependencies/eigen

RUN cd dependencies/eigen \
        && mkdir -p build \
        && cd build \
        && cmake ../ -DBLAS_DIR="/usr/include/openblas"\
        && make install

ADD https://github.com/jianyangqt/gcta.git#v1.94.1 ./codebase

ENV BOOST_LIB="/usr/include/boost/include" \
        EIGEN3_INCLUDE_DIR="/usr/include/eigen3" \
        OPENBLAS="/usr/include/openblas" \
        SPECTRA_LIB="/usr/include/Spectra"

RUN cd codebase \
        && mkdir -p build \
        && cd build \
        && cmake ../ \
        && make \
        && cp gcta64 /usr/bin \
        && ln -s /usr/bin/gcta64 /usr/bin/gcta

FROM ubuntu:24.04@sha256:72297848456d5d37d1262630108ab308d3e9ec7ed1c3286a32fe09856619a782 AS production

COPY --from=build /lib /lib
COPY --from=build /usr /usr

WORKDIR /workspace/program/gcta/production
