# TASSEL Container User Guide

This document provides instructions for building and using a Docker container for TASSEL analysis. This guide assumes you have Docker installed on your system and basic familiarity with command-line operations.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Setup](#setup)
3. [Building the Container](#building-the-container)
4. [Verifying the Build](#verifying-the-build)
5. [Running the Container](#running-the-container)
6. [Verifying Container Environment](#verifying-container-environment)
7. [Exiting the Container](#exiting-the-container)
8. [Advanced Usage](#advanced-usage)

## Prerequisites

- Docker installed on your system
- The project repository cloned or unzipped
- Basic familiarity with terminal commands

## Setup

1. Navigate to the project's root directory in your terminal.
2. Change to the `tools/tassel` directory:

```bash
cd /path/to/gwas-toolkit/tools/tassel
```

## Building the Container

To build the TASSEL Docker container from scratch, use the `docker buildx build` command. This command compiles the container according to the specifications in the Dockerfile.

```bash
docker buildx build --iidfile tassel_container_iid.txt --tag tassel-container:dev .
```

Parameters explained:
- `--iidfile tassel_container_iid.txt`: Saves the container ID to a file
- `--tag tassel-container:dev`: Tags the container with the name "tassel-container" and version "dev"
- `.`: Specifies that the Dockerfile is in the current directory

During building, the process includes:
1. Pulling the base Ubuntu 24.04 image
2. Setting up the working environment
3. Installing OpenJDK 8 JRE headless
4. Downloading TASSEL 5.2.95 from Bitbucket

A successful build will end with a message indicating the image has been built and named:

```text
=> naming to docker.io/library/tassel-container:dev
```

## Verifying the Build

To verify that your container has been built successfully, use:

```bash
docker image ls
```

This command lists all Docker images on your system. You should see your newly built image:

```bash
REPOSITORY        TAG     IMAGE ID       CREATED         SIZE
tassel-container  dev     b2686f5bda1a   3 minutes ago   XXXMB
```

You can also check the container ID by displaying the contents of the ID file:

```bash
cat tassel_container_iid.txt
```

This should show the SHA256 hash of your container.

## Running the Container

To run the container with access to your data files, use the `docker container run` command with bind mounting:

```bash
docker container run -it --mount type=bind,src=./tassel-resources/input,dst=/workspace/program/tassel/input --mount type=bind,src=./tassel-resources/output,dst=/workspace/program/tassel/output tassel-container:dev /bin/bash
```

Parameters explained:
- `-it`: Allocates an interactive terminal for the container
- `--mount type=bind,src=./tassel-resources/input,dst=/workspace/program/tassel/input`: Creates a bind mount for input data
  - `src=./tassel-resources/input`: Source input directory on your host machine
  - `dst=/workspace/program/tassel/input`: Input mount point inside the container
- `--mount type=bind,src=./tassel-resources/output,dst=/workspace/program/tassel/output`: Creates a bind mount for output data
  - `src=./tassel-resources/output`: Source output directory on your host machine
  - `dst=/workspace/program/tassel/output`: Output mount point inside the container
- `tassel-container:dev`: The name and tag of the container to run
- `/bin/bash`: The command to execute (starts a bash shell)

When executed successfully, your terminal prompt will change to indicate you're inside the container.

## Verifying Container Environment

Once inside the container, verify your environment:

1. Check your user identity within the container:
   ```bash
   whoami
   ```
   You should see that you're running as `root`.

2. Verify your current working directory:
   ```bash
   pwd
   ```
   You should be in the default workspace:
   ```bash
   /workspace/program/tassel
   ```

3. Confirm your data directories are properly mounted:
   ```bash
   ls -hl
   ```
   You should see `input` and `output` directories among other files.

4. Verify that Java is installed and working:
   ```bash
   java -version
   ```
   Output should show that OpenJDK 8 is installed.

5. Check that TASSEL is available:
   ```bash
   cd production
   ls -la
   ```
   You should see the TASSEL program files.

6. Verify TASSEL works by checking its version:
   ```bash
   ./run_pipeline.pl -version
   ```
   This should display the TASSEL version information (5.2.95).

## Exiting the Container

To exit the container, simply type:

```bash
exit
```

This will return you to your host system's terminal.

## Advanced Usage

### Running TASSEL Analyses

You can run TASSEL analyses inside the container according to the TASSEL user manual. The key points to remember:

- Input data should be in the mounted `/workspace/program/tassel/input` directory
- Output should be directed to the `/workspace/program/tassel/output` directory
- This ensures your data and results are persisted on your host system

### Using Alternative Mount Points

If your data is organized differently, you can adjust the mount points:

```bash
docker container run -it --mount type=bind,src=/path/to/my/data,dst=/workspace/program/tassel/mydata tassel-container:dev /bin/bash
```
