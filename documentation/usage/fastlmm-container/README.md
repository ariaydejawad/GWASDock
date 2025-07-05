# FaST-LMM Container User Guide

This document provides instructions for building and using a Docker container for FaST-LMM analysis. This guide assumes you have Docker installed on your system and basic familiarity with command-line operations.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Setup](#setup)
3. [Building the Container](#building-the-container)
4. [Verifying the Build](#verifying-the-build)
5. [Running the Container](#running-the-container)
6. [Verifying Container Environment](#verifying-container-environment)
7. [Using FaST-LMM in the Container](#using-fastlmm-in-the-container)
8. [Exiting the Container](#exiting-the-container)

## Prerequisites

- Docker installed on your system
- The project repository cloned or unzipped
- Basic familiarity with terminal commands

## Setup

1. Navigate to the project's root directory in your terminal.
2. Change to the `tools/fastlmm` directory:

```bash
cd /path/to/gwas-toolkit/tools/fastlmm
```

## Building the Container

To build the FaST-LMM Docker container from scratch, use the `docker buildx build` command.

This command compiles the container according to the specifications in the Dockerfile.

```bash
docker buildx build --iidfile fastlmm_container_iid.txt --tag fastlmm-container:dev .
```

Parameters explained:
- `--iidfile fastlmm_container_iid.txt`: Saves the container ID to a file
- `--tag fastlmm-container:dev`: Tags the container with the name "fastlmm-container" and version "dev"
- `.`: Specifies that the Dockerfile is in the current directory

During building, the process includes:
1. Pulling the base Python 3.13 image
2. Setting up the working environment at `/workspace/program/fastlmm`
3. Installing required dependencies (Python and libraries)

A successful build will end with a message indicating the image has been built and named, like so:

```text
=> naming to docker.io/library/fastlmm-container:dev
```

## Verifying the Build

To verify that your container has been built successfully, use:

```bash
docker image ls
```

This command lists all Docker images on your system. You should see your newly built image:

```text
REPOSITORY        TAG     IMAGE ID       CREATED         SIZE
fastlmm-container   dev     b2686f5bda1a   3 minutes ago   XXXMB
```

You can also check the container ID by displaying the contents of the ID file:

```bash
cat fastlmm_container_iid.txt
```

This should show the SHA256 hash of your container.

## Running the Container

To run the container with access to your data files and scripts, use the `docker container run` command with bind mounting:

```bash
docker container run -it --mount type=bind,src=<your-input-folder-path>,dst=/workspace/program/fastlmm/input --mount type=bind,src=<your-output-folder-path>,dst=/workspace/program/fastlmm/output --mount type=bind,src=<your-scripts-folder-path>,dst=/workspace/program/fastlmm/user-scripts fastlmm-container:dev /bin/bash
```

Parameters explained:
- `-it`: Allocates an interactive terminal for the container
- `--mount type=bind,src=<your-input-folder-path>,dst=/workspace/program/fastlmm/input`: Creates a bind mount for input data inside the FaST-LMM container based on where your input data files are located on your system.
- `--mount type=bind,src=<your-output-folder-path>,dst=/workspace/program/fastlmm/output`: Creates a bind mount for output data inside the FaST-LMM container based on where you want to store your FaST-LMM output analysis files on your system.
- `--mount type=bind,src=<your-scripts-folder-path>,dst=/workspace/program/fastlmm/user-scripts`: Creates a bind mount for user Python scripts inside the FaST-LMM container based on where you have your faST-LMM Python scripts/programs on your system.
- `fastlmm-container:dev`: The name and tag of the container to run
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
```text
/workspace/program/fastlmm
```

3. Confirm your mounted directories are properly available:
```bash
ls -hl
```
You should see `input`, `output`, and `user-scripts` directories among other files and directories.

4. Verify that Python is installed and working:
``` bash
python --version
```
Output should show the Python version information.

5. Start the FaST-LMM Python virtual environment next (this is very important).
```bash
source fastlmm-venv/bin/activate
```
If successful, you should see the name of the FaST-LMM Python virtual environment in your command prompt instead of the usual bash prompt.

For example, you should see a similar prompt to the one below:
```bash
(fastlmm-venv) root@91982250a07e:/workspace/program/fastlmm#
```

6. Check that FaST-LMM is available in your Python virtual environment:
``` bash
pip freeze
```
This command will print a list of all installed Python packages in your FaST-LMM virtual environment.

If you can see `fastlmm==0.6.12` and `fastlmmclib==0.0.7` installed in the output of the freezing command, then you indeed have `fastlmm` installed correctly, and it is ready to be used.

## Using FaST-LMM in the Container
Note: This section assumes you have the FaST-LMM virtual environment activated from the previous section. You must have the Python FaST-LMM virtual environment running for any of the steps below to work correctly.

Since FaST-LMM is a Python library, you will interact with it through Python scripts:

1. To run a FaST-LMM script that you've mounted to the container:
```bash
python ./user-scripts/<name-of-your-python-script-or-program>
```
If you have correctly mounted your scripts from the previous steps, they will be fully visible to the FaST-LMM container runtime environment. You can choose to provide any of the FaST-LMM scripts in the directory containing your scripts to the Python interpreter located within the container runtime environment for analysis. Just be sure to provide the correct input and output file directories in your Python scripts/programs.

Based on the code you have in your Python script/program, FaST-LMM will output its analyses files in the output directory you specified. If the mounting step in the previous section was done correctly, then you will see FaST-LMM's analysis results in there. These files will persist on your computer's local file system even after the FaST-LMM container is stopped and destroyed, so they are yours to keep.

## Exiting the Container

To exit the container, simply type:

```bash
exit
```

This will return you to your host system's terminal.
