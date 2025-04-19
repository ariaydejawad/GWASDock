FROM python:3.13@sha256:0d46ec7010093c2a30ae712c3d6fc9d3938ae8d31dcf38c14deee3e43f88e6ca

SHELL ["/bin/bash", "-c"]
WORKDIR /workspace/program/fast-lmm

ADD https://github.com/fastlmm/FaST-LMM.git#v0.6.12 ./codebase

RUN python -m venv fastlmm-venv
ADD fastlmm-resources/requirements.txt ./fastlmm-venv

RUN source fastlmm-venv/bin/activate \
	&& cd fastlmm-venv \
	&& pip install -r requirements.txt

ADD fastlmm-resources/scripts ./testing
