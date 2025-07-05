#!/bin/bash

# --- Configuration ---
# Define the project root directory. Adjust as needed.
# It is recommended to place this script in the parent directory where you want the GWASDock repository to be cloned.
PROJECT_ROOT_DIR="/Users/dong/Project/GWASDock" 

# GWASDock repository URL
GWASDOCK_REPO_URL="https://github.com/ariaydejawad/yyan-gwas-toolkit.git"
GWASDOCK_REPO_NAME="yyan-gwas-toolkit"

# Relative path to the FaST-LMM tool directory within the repository
FASTLMM_TOOL_DIR="./tools/fastlmm"

# Docker image name
DOCKER_IMAGE_NAME="fastlmm-container:dev"

# Local data directories on the host system. PLEASE MODIFY THESE PATHS!
# Example: If your data is in /home/user/my_gwas_data/input on your host machine
LOCAL_INPUT_DIR="/Users/dong/Project/GWASDock/fastlmm-resource/input"  
LOCAL_OUTPUT_DIR="/Users/dong/Project/GWASDock/fastlmm-resource/output" 

# Data directories inside the container (expected paths by the FaST-LMM program)
CONTAINER_INPUT_DIR="/workspace/program/fast-lmm/input"
CONTAINER_OUTPUT_DIR="/workspace/program/fast-lmm/output"

# --- Functions ---
# Function to print info messages in blue
log_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

# Function to print success messages in green
log_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

# Function to print error messages in red and exit
log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
    exit 1
}

# --- Main Script ---

# Step 1. Change to the project root directory
# Ensure the project root directory exists and change to it
mkdir -p "$PROJECT_ROOT_DIR" || { echo "Cannot create directory $PROJECT_ROOT_DIR"; exit 1; }
cd "$PROJECT_ROOT_DIR" || { echo "Failed to change directory to $PROJECT_ROOT_DIR"; exit 1; }

log_info "--- GWASDock FaST-LMM Setup Script ---"

# Step 2. Clone the GWASDock Repository if it doesn't exist
if [ -d "$GWASDOCK_REPO_NAME" ]; then
    log_info "GWASDock repository '$GWASDOCK_REPO_NAME' already exists. Skipping clone."
    cd "$GWASDOCK_REPO_NAME" || log_error "Failed to change directory to $GWASDOCK_REPO_NAME"
else
    log_info "Cloning GWASDock repository: $GWASDOCK_REPO_URL"
    git clone "$GWASDOCK_REPO_URL" || log_error "Failed to clone repository."
    cd "$GWASDOCK_REPO_NAME" || log_error "Failed to change directory to $GWASDOCK_REPO_NAME"
fi

# Step 3. Check if Docker is installed
if ! command -v docker &> /dev/null
then
    log_error "Docker is not installed. Please install Docker before running this script."
fi

# Step 4. Build FaST-LMM Docker Image
log_info "Navigating to FaST-LMM tool directory: $FASTLMM_TOOL_DIR"
cd "$FASTLMM_TOOL_DIR" || log_error "Failed to change directory to $FASTLMM_TOOL_DIR. Make sure it exists."

log_info "Building Docker image: $DOCKER_IMAGE_NAME"
docker buildx build \
  --iidfile fastlmm_container_iid.txt \
  --tag "$DOCKER_IMAGE_NAME" . || log_error "Failed to build Docker image."

log_success "Docker image '$DOCKER_IMAGE_NAME' built successfully."

# Step5 . Return to main repository directory
cd "$PROJECT_ROOT_DIR/$GWASDOCK_REPO_NAME" || log_error "Failed to return to project root directory after image build."

# Step6. Ensure local data directories exis
if [ ! -d "$LOCAL_INPUT_DIR" ]; then
    log_info "Local input directory '$LOCAL_INPUT_DIR' does not exist. Creating it."
    mkdir -p "$LOCAL_INPUT_DIR" || log_error "Failed to create local input directory."
fi
if [ ! -d "$LOCAL_OUTPUT_DIR" ]; then
    log_info "Local output directory '$LOCAL_OUTPUT_DIR' does not exist. Creating it."
    mkdir -p "$LOCAL_OUTPUT_DIR" || log_error "Failed to create local output directory."
fi

# Step7.  Run the Container 
log_info "Running FaST-LMM container with bind mounts..."
log_info "Mapping local input: $LOCAL_INPUT_DIR -> Container input: $CONTAINER_INPUT_DIR"
log_info "Mapping local output: $LOCAL_OUTPUT_DIR -> Container output: $CONTAINER_OUTPUT_DIR"

# Command to run the container. Using --rm ensures the container is automatically removed upon exit to avoid clutter.
# Remove --rm if you wish to keep the container after it exits.
docker container run -it --rm \
  --mount type=bind,source="$LOCAL_INPUT_DIR",target="$CONTAINER_INPUT_DIR" \
  --mount type=bind,source="$LOCAL_OUTPUT_DIR",target="$CONTAINER_OUTPUT_DIR" \
  "$DOCKER_IMAGE_NAME" /bin/bash

log_success "Container command executed. You should now be inside the container's bash shell."
log_info "From inside the container, your input data will be accessible at '$CONTAINER_INPUT_DIR' and output results at '$CONTAINER_OUTPUT_DIR'."
log_info "To exit the container, type 'exit' and press Enter."