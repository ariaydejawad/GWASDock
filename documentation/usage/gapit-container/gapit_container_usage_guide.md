# GAPIT Container User Guide

This document provides instructions for building and using a Docker container for GAPIT analysis. This guide assumes you have Docker installed on your system and basic familiarity with command-line operations.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Setup](#setup)
3. [Building the Container](#building-the-container)
4. [Verifying the Build](#verifying-the-build)
5. [Running the Container](#running-the-container)
6. [Verifying Container Environment](#verifying-container-environment)
7. [Using GAPIT in the Container](#using-gapit-in-the-container)
8. [Exiting the Container](#exiting-the-container)
9. [Advanced Usage](#advanced-usage)

## Prerequisites

- Docker installed on your system
- The project repository cloned or unzipped
- Basic familiarity with terminal commands

## Setup

1. Navigate to the project's root directory in your terminal.
2. Change to the `tools/gapit` directory:

```bash
cd /path/to/gwas-toolkit/tools/gapit
```

## Building the Container

To build the GAPIT Docker container from scratch, use the `docker buildx build` command. This command compiles the container according to the specifications in the Dockerfile.

```bash
docker buildx build --iidfile gapit_container_iid.txt --tag gapit-container:dev .
```

Parameters explained:
- `--iidfile gapit_container_iid.txt`: Saves the container ID to a file
- `--tag gapit-container:dev`: Tags the container with the name "gapit-container" and version "dev"
- `.`: Specifies that the Dockerfile is in the current directory

During building, the process includes:
1. Pulling the base Ubuntu 24.04 image
2. Setting up the working environment at `/app/workspace/gapit`
3. Installing required dependencies (R, build tools, and libraries)
4. Running the `install_gapit.R` script which installs the GAPIT package from GitHub

A successful build will end with a message indicating the image has been built and named:

```text
=> naming to docker.io/library/gapit-container:dev
```

## Verifying the Build

To verify that your container has been built successfully, use:

```bash
docker image ls
```

This command lists all Docker images on your system. You should see your newly built image:

```text
REPOSITORY        TAG     IMAGE ID       CREATED         SIZE
gapit-container   dev     b2686f5bda1a   3 minutes ago   XXXMB
```

You can also check the container ID by displaying the contents of the ID file:

```bash
cat gapit_container_iid.txt
```

This should show the SHA256 hash of your container.

## Running the Container

To run the container with access to your data files and scripts, use the `docker container run` command with bind mounting:

```bash
docker container run -it --mount type=bind,src=./gapit-resources/input,dst=/app/workspace/gapit/input --mount type=bind,src=./gapit-resources/output,dst=/app/workspace/gapit/output --mount type=bind,src=./gapit-resources/scripts,dst=/app/workspace/gapit/user-scripts gapit-container:dev /bin/bash
```

Parameters explained:
- `-it`: Allocates an interactive terminal for the container
- `--mount type=bind,src=./gapit-resources/input,dst=/app/workspace/gapit/input`: Creates a bind mount for input data
- `--mount type=bind,src=./gapit-resources/output,dst=/app/workspace/gapit/output`: Creates a bind mount for output data
- `--mount type=bind,src=./gapit-resources/scripts,dst=/app/workspace/gapit/user-scripts`: Creates a bind mount for custom R scripts, including any demo scripts like `gapit_demo.R`
- `gapit-container:dev`: The name and tag of the container to run
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
   /app/workspace/gapit
   ```

3. Confirm your mounted directories are properly available:
   ```bash
   ls -hl
   ```
   You should see `input`, `output`, and `user-scripts` directories among other files and directories.

4. Verify that R is installed and working:
   ``` bash
   R --version
   ```
   Output should show the R version information.

5. Check that GAPIT is available in R:
   ``` bash
   R -e 'library(GAPIT)'
   ```
   If this command runs without errors, GAPIT is properly installed.

## Using GAPIT in the Container

Since GAPIT is an R library, you'll interact with it through R scripts:

1. Launch R from the container's command line:
   ```bash
   R
   ```

2. Load the GAPIT library:
   ```r
   library(GAPIT)
   ```

3. Run your GAPIT analysis using R commands:
   ```r
   # Load your data
   myY <- read.table('/app/workspace/gapit/input/my_phenotype.txt', header=TRUE)
   myGD <- read.table('/app/workspace/gapit/input/my_genotype.txt', header=TRUE)
   myGM <- read.table('/app/workspace/gapit/input/my_map.txt', header=TRUE)

   # Run GAPIT
   myGAPIT <- GAPIT(
     Y=myY,
     GD=myGD,
     GM=myGM,
     output.dir='/app/workspace/gapit/output/'
   )
   ```

4. To run a demo or custom script that you've mounted to the container:
   ```bash
   Rscript /app/workspace/gapit/user-scripts/gapit_demo.R
   ```

The results will be saved to your output directory, which is mounted to your host system, ensuring that your analysis results persist after exiting the container.

## Exiting the Container

To exit the container, simply type:

```bash
exit
```

This will return you to your host system's terminal.

## Advanced Usage

### Using the Demo Script

The `gapit_demo.R` script is not included in the container by default, but you can prepare it in your local environment and mount it to the container. This script demonstrates GAPIT's functionality using example data from the Z. Zhang Lab:

1. Create a `scripts` directory in your local project:
   ```bash
   mkdir -p ./gapit-resources/scripts
   ```

2. Create a file named `gapit_demo.R` in the scripts directory with the following content:
   ```r
   library(GAPIT)

   # Import data from Z. Zhang Lab
   myY <- read.table('http://zzlab.net/GAPIT/data/mdp_traits.txt', head = TRUE)
   myGD = read.table(file = 'http://zzlab.net/GAPIT/data/mdp_numeric.txt', head = T)
   myGM = read.table(file = 'http://zzlab.net/GAPIT/data/mdp_SNP_information.txt', head = T)

   # Perform a Genome-Wide Association Study on 'toy' data
   myGAPIT = GAPIT(Y = myY[,c(1,2,3)], GD = myGD, GM = myGM,
                  PCA.total = 3,
                  model = c('FarmCPU', 'BLINK'),
                  Multiple_analysis = TRUE,
                  output.dir = '/app/workspace/gapit/output/')
   ```

3. Run the container with the script directory mounted:
   ```bash
   docker container run -it --mount type=bind,src=./gapit-resources/input,dst=/app/workspace/gapit/input --mount type=bind,src=./gapit-resources/output,dst=/app/workspace/gapit/output --mount type=bind,src=./gapit-resources/scripts,dst=/app/workspace/gapit/user-scripts gapit-container:dev /bin/bash
   ```

4. Inside the container, run the demo script:
   ```r
   Rscript /app/workspace/gapit/user-scripts/gapit_demo.R
   ```

### Running Non-Interactive Commands

For automation, you can run R scripts without an interactive shell:

```bash
docker container run --mount type=bind,src=./gapit-resources/input,dst=/app/workspace/gapit/input --mount type=bind,src=./gapit-resources/output,dst=/app/workspace/gapit/output --mount type=bind,src=./gapit-resources/scripts,dst=/app/workspace/gapit/user-scripts gapit-container:dev Rscript /app/workspace/gapit/user-scripts/batch_analysis.R
```

This executes the R script and then exits the container.

### Creating Custom Analysis Workflows

You can create custom R scripts for your specific analysis needs and mount them to the container. By directing the output to your mounted output directory, all results will be available on your host system after the container exits.
