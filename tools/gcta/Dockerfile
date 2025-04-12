FROM ubuntu:24.04@sha256:72297848456d5d37d1262630108ab308d3e9ec7ed1c3286a32fe09856619a782 AS boost-build

WORKDIR /workspace/program/gcta

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        g++ \
        gcc \
        make \
        wget

RUN mkdir -p dependencies \
        && cd dependencies \
        && wget https://archives.boost.io/release/1.82.0/source/boost_1_82_0.tar.gz \
        && tar -xzvf boost_1_82_0.tar.gz \
        && rm boost_1_82_0.tar.gz

RUN cd dependencies/boost_1_82_0 \
        && ./bootstrap.sh \
        && ./b2 \
        && ./b2 headers \
        && ./b2 install

FROM ubuntu:24.04@sha256:72297848456d5d37d1262630108ab308d3e9ec7ed1c3286a32fe09856619a782 AS openblas-build

WORKDIR /workspace/program/gcta

RUN apt-get update && apt-get install -y --no-install-recommends \
        cmake \
        g++ \
        gcc \
        gfortran \
        make

ADD https://github.com/OpenMathLib/OpenBLAS.git#v0.3.15 ./dependencies/openblas

RUN cd dependencies/openblas \
        && make \
        && make install PREFIX="/usr/include/openblas"

FROM ubuntu:24.04@sha256:72297848456d5d37d1262630108ab308d3e9ec7ed1c3286a32fe09856619a782 AS eigen-build

COPY --from=boost-build /usr/local/include/boost /usr/include/boost
COPY --from=openblas-build /usr/include/openblas /usr/include/openblas

RUN apt-get update && apt-get install -y --no-install-recommends \
        cmake \
        g++ \
        gcc \
        make

WORKDIR /workspace/program/gcta

ADD https://gitlab.com/libeigen/eigen.git#3.3.7 ./dependencies/eigen

RUN cd dependencies/eigen \
        && mkdir -p build \
        && cd build \
        && cmake ../ -DBLAS_DIR="/usr/include/openblas"\
        && make install

FROM ubuntu:24.04@sha256:72297848456d5d37d1262630108ab308d3e9ec7ed1c3286a32fe09856619a782 AS main-gcta-build

WORKDIR /workspace/program/gcta

COPY --from=eigen-build /usr/include/boost /usr/include/boost
COPY --from=eigen-build /usr/include/openblas /usr/include/openblas
COPY --from=eigen-build /usr/local/include/eigen3 /usr/include/eigen3

RUN apt-get update && apt-get install -y --no-install-recommends \
        cmake \
        g++-12 \
        gcc-12 \
        gfortran-12 \
        libgsl-dev \
        libspectra-dev \
        libsqlite3-dev \
        libzstd-dev \
        make \
        zlib1g-dev

ADD https://github.com/jianyangqt/gcta.git#v1.94.1 ./codebase

ENV BOOST_LIB="/usr/include/boost" \
        CC="/usr/bin/gcc-12" \
        CXX="/usr/bin/g++-12" \
        EIGEN3_INCLUDE_DIR="/usr/include/eigen3" \
        FC="/usr/bin/gfortran-12" \
        OPENBLAS="/usr/include/openblas" \
        SPECTRA_LIB="/usr/include/Spectra"

RUN cd codebase \
        && mkdir -p build \
        && cd build \
        && cmake ../ \
        && make
