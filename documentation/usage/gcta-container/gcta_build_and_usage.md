# GCTA Container Runtime Environment - Build & Usage Instructions

## Overview
This document provides instructions for building and using the GCTA container runtime environment via Docker.

## Build Instructions

### Platform-Specific Dockerfiles
- **For ARM (aarch64) machines**: Use `Dockerfile.aarch64`
- **For x86_64 (amd64) machines**: Use `Dockerfile.amd64`

### Building for AMD64 Systems
Run the following command from the project's root directory:

```sh
docker buildx build --file tools/gcta/Dockerfile.amd64 --platform=linux/amd64 --iidfile tools/gcta/gcta_iid.txt --tag gcta:dev .
```

### Building for ARM64 Systems
Run the following command from the project's root directory:

```sh
docker buildx build --file tools/gcta/Dockerfile.aarch64 --platform=linux/arm64 --iidfile tools/gcta/gcta_iid.txt --tag gcta:dev .
```

## Usage Instructions
To use the GCTA container:
1. Run the following command to enter the container:
```sh
docker container run -it gcta:dev
```
2. Once inside the container, you can start using GCTA as normal, like so:
```sh
gcta
```

### Notes
* The usage pattern is identical to the other GWAS container runtime environments in the project
* Use the Dockerfile that matches your system architecture