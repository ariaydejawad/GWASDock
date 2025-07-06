#!/bin/bash

# PLINK Data Format Conversion Script
# This script automates the process of converting genomic data formats using PLINK in Docker

set -e  # Exit on any error

# Function to display usage
usage() {
    echo "Usage: $0 -i <input_dir> -o <output_dir> -f <input_format> [options]"
    echo ""
    echo "Required arguments:"
    echo "  -i <input_dir>     Path to directory containing input files"
    echo "  -o <output_dir>    Path to directory for output files"
    echo "  -f <input_format>  Input format: 'text' (for .ped/.map) or 'binary' (for .bed/.bim/.fam)"
    echo ""
    echo "Optional arguments:"
    echo "  -n <base_name>     Base name for input files (default: extracted from first .ped/.bed file)"
    echo "  -t <target_format> Target format: 'vcf', 'oxford', or 'both' (default: both)"
    echo "  -h                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  # Convert text PLINK files to VCF and Oxford formats"
    echo "  $0 -i /path/to/input -o /path/to/output -f text"
    echo ""
    echo "  # Convert binary PLINK files to VCF only"
    echo "  $0 -i /path/to/input -o /path/to/output -f binary -t vcf"
    echo ""
    echo "  # Convert with specific base name"
    echo "  $0 -i /path/to/input -o /path/to/output -f text -n hapmap1"
}

# Initialize variables
INPUT_DIR=""
OUTPUT_DIR=""
INPUT_FORMAT=""
BASE_NAME=""
TARGET_FORMAT="both"

# Parse command line arguments
while getopts "i:o:f:n:t:h" opt; do
    case $opt in
        i)
            INPUT_DIR="$OPTARG"
            ;;
        o)
            OUTPUT_DIR="$OPTARG"
            ;;
        f)
            INPUT_FORMAT="$OPTARG"
            ;;
        n)
            BASE_NAME="$OPTARG"
            ;;
        t)
            TARGET_FORMAT="$OPTARG"
            ;;
        h)
            usage
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$INPUT_DIR" || -z "$OUTPUT_DIR" || -z "$INPUT_FORMAT" ]]; then
    echo "Error: Missing required arguments"
    usage
    exit 1
fi

# Validate input format
if [[ "$INPUT_FORMAT" != "text" && "$INPUT_FORMAT" != "binary" ]]; then
    echo "Error: Input format must be 'text' or 'binary'"
    exit 1
fi

# Validate target format
if [[ "$TARGET_FORMAT" != "vcf" && "$TARGET_FORMAT" != "oxford" && "$TARGET_FORMAT" != "both" ]]; then
    echo "Error: Target format must be 'vcf', 'oxford', or 'both'"
    exit 1
fi

# Validate directories
if [[ ! -d "$INPUT_DIR" ]]; then
    echo "Error: Input directory does not exist: $INPUT_DIR"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Convert to absolute paths
INPUT_DIR=$(realpath "$INPUT_DIR")
OUTPUT_DIR=$(realpath "$OUTPUT_DIR")

# Auto-detect base name if not provided
if [[ -z "$BASE_NAME" ]]; then
    if [[ "$INPUT_FORMAT" == "text" ]]; then
        # Look for .ped files
        PED_FILE=$(find "$INPUT_DIR" -name "*.ped" -type f | head -1)
        if [[ -n "$PED_FILE" ]]; then
            BASE_NAME=$(basename "$PED_FILE" .ped)
        else
            echo "Error: No .ped files found in input directory"
            exit 1
        fi
    else
        # Look for .bed files
        BED_FILE=$(find "$INPUT_DIR" -name "*.bed" -type f | head -1)
        if [[ -n "$BED_FILE" ]]; then
            BASE_NAME=$(basename "$BED_FILE" .bed)
        else
            echo "Error: No .bed files found in input directory"
            exit 1
        fi
    fi
fi

echo "=== PLINK Data Conversion Script ==="
echo "Input directory: $INPUT_DIR"
echo "Output directory: $OUTPUT_DIR"
echo "Input format: $INPUT_FORMAT"
echo "Base name: $BASE_NAME"
echo "Target format: $TARGET_FORMAT"
echo ""

# Navigate to PLINK tools directory
echo "Navigating to PLINK tools directory..."
cd ../../tools/plink

# Build PLINK Docker image
echo "Building PLINK Docker image..."
docker buildx build --tag plink:dev --iidfile plink_iid.txt .

echo "PLINK Docker image built successfully!"
echo ""

# Define container paths
CONTAINER_INPUT_DIR="/data/input"
CONTAINER_OUTPUT_DIR="/data/output"

# Function to run PLINK commands in container
run_plink_command() {
    local cmd="$1"
    local description="$2"

    echo "Running: $description"
    echo "Command: $cmd"

    docker container run --rm \
        --mount type=bind,src="$INPUT_DIR",dst="$CONTAINER_INPUT_DIR",ro \
        --mount type=bind,src="$OUTPUT_DIR",dst="$CONTAINER_OUTPUT_DIR" \
        plink:dev \
        $cmd

    echo "✓ $description completed successfully!"
    echo ""
}

# Step 1: Convert to binary format if input is text
if [[ "$INPUT_FORMAT" == "text" ]]; then
    echo "=== Step 1: Converting text PLINK to binary PLINK ==="
    BINARY_BASE_NAME="${BASE_NAME}_binary"

    run_plink_command \
        "plink --file $CONTAINER_INPUT_DIR/$BASE_NAME --make-bed --out $CONTAINER_OUTPUT_DIR/$BINARY_BASE_NAME" \
        "Text to binary PLINK conversion"
else
    # If input is already binary, just use the original base name
    BINARY_BASE_NAME="$BASE_NAME"
    echo "Input is already in binary format, skipping conversion to binary."
    echo ""
fi

# Step 2: Convert to target formats
if [[ "$TARGET_FORMAT" == "vcf" || "$TARGET_FORMAT" == "both" ]]; then
    echo "=== Converting binary PLINK to VCF format ==="

    if [[ "$INPUT_FORMAT" == "text" ]]; then
        # Use the binary files we just created
        run_plink_command \
            "plink --bfile $CONTAINER_OUTPUT_DIR/$BINARY_BASE_NAME --recode vcf --out $CONTAINER_OUTPUT_DIR/${BASE_NAME}_vcf" \
            "Binary PLINK to VCF conversion"
    else
        # Use the original binary files from input directory
        run_plink_command \
            "plink --bfile $CONTAINER_INPUT_DIR/$BASE_NAME --recode vcf --out $CONTAINER_OUTPUT_DIR/${BASE_NAME}_vcf" \
            "Binary PLINK to VCF conversion"
    fi
fi

if [[ "$TARGET_FORMAT" == "oxford" || "$TARGET_FORMAT" == "both" ]]; then
    echo "=== Converting binary PLINK to Oxford format ==="

    if [[ "$INPUT_FORMAT" == "text" ]]; then
        # Use the binary files we just created
        run_plink_command \
            "plink --bfile $CONTAINER_OUTPUT_DIR/$BINARY_BASE_NAME --recode oxford --out $CONTAINER_OUTPUT_DIR/${BASE_NAME}_oxford" \
            "Binary PLINK to Oxford conversion"
    else
        # Use the original binary files from input directory
        run_plink_command \
            "plink --bfile $CONTAINER_INPUT_DIR/$BASE_NAME --recode oxford --out $CONTAINER_OUTPUT_DIR/${BASE_NAME}_oxford" \
            "Binary PLINK to Oxford conversion"
    fi
fi

echo "=== Conversion Complete! ==="
echo "All output files have been saved to: $OUTPUT_DIR"
echo ""
echo "Generated files:"
ls -la "$OUTPUT_DIR"
echo ""
echo "🎉 PLINK data conversion completed successfully!"
