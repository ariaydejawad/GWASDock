#!/bin/bash

# Genomic Data Format Conversion Script
# This script automates the process of converting genomic data formats using PLINK and TASSEL in Docker

set -e  # Exit on any error

# Function to display usage
usage() {
    echo "Usage: $0 -i <input_dir> -o <output_dir> -f <input_format> [options]"
    echo ""
    echo "Required arguments:"
    echo "  -i <input_dir>     Path to directory containing input files"
    echo "  -o <output_dir>    Path to directory for output files"
    echo "  -f <input_format>  Input format: 'text' (for .ped/.map), 'binary' (for .bed/.bim/.fam), 'vcf' (for .vcf), or 'hapmap' (for .hmp.txt)"
    echo ""
    echo "Optional arguments:"
    echo "  -n <base_name>     Base name for input files (default: extracted from first .ped/.bed/.vcf file)"
    echo "  -t <target_format> Target format: 'vcf', 'oxford', 'binary', 'text', 'hapmap', or 'both' (default: auto)"
    echo "  -T <tool>          Tool to use: 'plink' or 'tassel' (default: auto-selected based on formats)"
    echo "  -h                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  # Convert VCF to binary PLINK only (auto-selects PLINK)"
    echo "  $0 -i /path/to/input -o /path/to/output -f vcf"
    echo ""
    echo "  # Convert binary PLINK to text PLINK format"
    echo "  $0 -i /path/to/input -o /path/to/output -f binary -t text"
    echo ""
    echo "  # Convert binary PLINK to HapMap format (auto-selects TASSEL, via text intermediate)"
    echo "  $0 -i /path/to/input -o /path/to/output -f binary -t hapmap"
    echo ""
    echo "  # Convert text PLINK to HapMap format (auto-selects TASSEL)"
    echo "  $0 -i /path/to/input -o /path/to/output -f text -t hapmap"
    echo ""
    echo "  # Convert HapMap to PLINK formats (auto-selects TASSEL)"
    echo "  $0 -i /path/to/input -o /path/to/output -f hapmap -t vcf"
    echo ""
    echo "  # Convert text PLINK files to VCF and Oxford formats (auto-selects PLINK)"
    echo "  $0 -i /path/to/input -o /path/to/output -f text"
    echo ""
    echo "  # Convert binary PLINK files to VCF only (auto-selects PLINK)"
    echo "  $0 -i /path/to/input -o /path/to/output -f binary -t vcf"
    echo ""
    echo "  # Convert with specific base name and tool"
    echo "  $0 -i /path/to/input -o /path/to/output -f text -n hapmap1 -T tassel -t hapmap"
}

# Initialize variables
INPUT_DIR=""
OUTPUT_DIR=""
INPUT_FORMAT=""
BASE_NAME=""
TARGET_FORMAT="auto"
TOOL="auto"

# Parse command line arguments
while getopts "i:o:f:n:t:T:h" opt; do
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
        T)
            TOOL="$OPTARG"
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
if [[ "$INPUT_FORMAT" != "text" && "$INPUT_FORMAT" != "binary" && "$INPUT_FORMAT" != "vcf" && "$INPUT_FORMAT" != "hapmap" ]]; then
    echo "Error: Input format must be 'text', 'binary', 'vcf', or 'hapmap'"
    exit 1
fi

# Validate target format
if [[ "$TARGET_FORMAT" != "vcf" && "$TARGET_FORMAT" != "oxford" && "$TARGET_FORMAT" != "binary" && "$TARGET_FORMAT" != "text" && "$TARGET_FORMAT" != "hapmap" && "$TARGET_FORMAT" != "both" && "$TARGET_FORMAT" != "auto" ]]; then
    echo "Error: Target format must be 'vcf', 'oxford', 'binary', 'text', 'hapmap', 'both', or 'auto'"
    exit 1
fi

# Validate tool
if [[ "$TOOL" != "plink" && "$TOOL" != "tassel" && "$TOOL" != "mixed" && "$TOOL" != "auto" ]]; then
    echo "Error: Tool must be 'plink', 'tassel', 'mixed', or 'auto'"
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
    elif [[ "$INPUT_FORMAT" == "binary" ]]; then
        # Look for .bed files
        BED_FILE=$(find "$INPUT_DIR" -name "*.bed" -type f | head -1)
        if [[ -n "$BED_FILE" ]]; then
            BASE_NAME=$(basename "$BED_FILE" .bed)
        else
            echo "Error: No .bed files found in input directory"
            exit 1
        fi
    elif [[ "$INPUT_FORMAT" == "vcf" ]]; then
        # Look for .vcf files
        VCF_FILE=$(find "$INPUT_DIR" -name "*.vcf" -type f | head -1)
        if [[ -n "$VCF_FILE" ]]; then
            BASE_NAME=$(basename "$VCF_FILE" .vcf)
        else
            echo "Error: No .vcf files found in input directory"
            exit 1
        fi
    else
        # Look for .hmp.txt files (HapMap format)
        HAPMAP_FILE=$(find "$INPUT_DIR" -name "*.hmp.txt" -type f | head -1)
        if [[ -n "$HAPMAP_FILE" ]]; then
            BASE_NAME=$(basename "$HAPMAP_FILE" .hmp.txt)
        else
            echo "Error: No .hmp.txt files found in input directory"
            exit 1
        fi
    fi
fi

# Set intelligent defaults for target format if auto
if [[ "$TARGET_FORMAT" == "auto" ]]; then
    if [[ "$INPUT_FORMAT" == "vcf" ]]; then
        TARGET_FORMAT="binary"
        echo "Auto-selected target format: binary (VCF → Binary PLINK)"
    elif [[ "$INPUT_FORMAT" == "binary" ]]; then
        TARGET_FORMAT="both"
        echo "Auto-selected target format: both VCF and Oxford (Binary PLINK → VCF + Oxford)"
    elif [[ "$INPUT_FORMAT" == "hapmap" ]]; then
        TARGET_FORMAT="vcf"
        echo "Auto-selected target format: vcf (HapMap → VCF)"
    else
        TARGET_FORMAT="both"
        echo "Auto-selected target format: both VCF and Oxford (Text PLINK → VCF + Oxford)"
    fi
    echo ""
fi

# Set intelligent defaults for tool if auto (HapMap handling takes priority)
if [[ "$TOOL" == "auto" ]]; then
    if [[ "$INPUT_FORMAT" == "binary" && "$TARGET_FORMAT" == "hapmap" ]]; then
        TOOL="mixed"
        echo "Auto-selected tool: Mixed (PLINK for binary→text, then TASSEL for text→HapMap)"
    elif [[ "$INPUT_FORMAT" == "hapmap" || "$TARGET_FORMAT" == "hapmap" ]]; then
        TOOL="tassel"
        echo "Auto-selected tool: TASSEL (required for HapMap format handling)"
    else
        TOOL="plink"
        echo "Auto-selected tool: PLINK"
    fi
    echo ""
fi

# Validate tool/format compatibility
if [[ "$TARGET_FORMAT" == "hapmap" && "$TOOL" != "tassel" && "$TOOL" != "mixed" ]]; then
    echo "Error: HapMap format conversion requires TASSEL. Use -T tassel or let auto-selection handle it."
    exit 1
fi

if [[ "$INPUT_FORMAT" == "hapmap" && "$TOOL" != "tassel" ]]; then
    echo "Error: HapMap input format requires TASSEL. Use -T tassel or let auto-selection handle it."
    exit 1
fi

if [[ "$INPUT_FORMAT" == "vcf" && "$TOOL" == "tassel" ]]; then
    echo "Error: VCF input is not supported with TASSEL. Use PLINK for VCF conversions."
    exit 1
fi

echo "=== Genomic Data Format Conversion Script ==="
echo "Input directory: $INPUT_DIR"
echo "Output directory: $OUTPUT_DIR"
echo "Input format: $INPUT_FORMAT"
echo "Base name: $BASE_NAME"
echo "Target format: $TARGET_FORMAT"
echo "Tool: $TOOL"
echo ""

# Navigate to tools directory and build appropriate Docker image(s)
if [[ "$TOOL" == "plink" ]]; then
    echo "Navigating to PLINK tools directory..."
    cd ../../tools/plink

    echo "Building PLINK Docker image..."
    docker buildx build --tag plink:dev --iidfile plink_iid.txt .
    echo "PLINK Docker image built successfully!"

elif [[ "$TOOL" == "tassel" ]]; then
    echo "Navigating to TASSEL tools directory..."
    cd ../../tools/tassel

    echo "Building TASSEL Docker image..."
    docker buildx build --tag tassel:dev --iidfile tassel_iid.txt .
    echo "TASSEL Docker image built successfully!"

elif [[ "$TOOL" == "mixed" ]]; then
    echo "Building both PLINK and TASSEL Docker images for mixed workflow..."

    echo "Navigating to PLINK tools directory..."
    cd ../../tools/plink
    docker buildx build --tag plink:dev --iidfile plink_iid.txt .
    echo "PLINK Docker image built successfully!"

    echo "Navigating to TASSEL tools directory..."
    cd ../tassel
    docker buildx build --tag tassel:dev --iidfile tassel_iid.txt .
    echo "TASSEL Docker image built successfully!"
fi

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

# Function to run TASSEL commands in container
run_tassel_command() {
    local cmd="$1"
    local description="$2"

    echo "Running: $description"
    echo "Command: $cmd"

    docker container run --rm \
        --mount type=bind,src="$INPUT_DIR",dst="/workspace/program/tassel/production/data/",ro \
        --mount type=bind,src="$OUTPUT_DIR",dst="/workspace/program/tassel/production/data/converted-datasets" \
        tassel:dev \
        $cmd

    echo "✓ $description completed successfully!"
    echo ""
}

# Handle mixed workflow (Binary PLINK → Text PLINK → HapMap)
if [[ "$TOOL" == "mixed" ]]; then
    if [[ "$INPUT_FORMAT" == "binary" && "$TARGET_FORMAT" == "hapmap" ]]; then
        echo "=== Mixed Workflow: Binary PLINK → Text PLINK → HapMap ==="

        # Step 1: Convert binary PLINK to text PLINK using PLINK
        echo "Step 1: Converting binary PLINK to text PLINK format..."
        TEXT_BASE_NAME="${BASE_NAME}_text"

        run_plink_command \
            "plink --bfile $CONTAINER_INPUT_DIR/$BASE_NAME --recode --out $CONTAINER_OUTPUT_DIR/$TEXT_BASE_NAME" \
            "Binary PLINK to text PLINK conversion"

        # Step 2: Convert text PLINK to HapMap using TASSEL
        # For this step, we need to mount the output directory as the input since the text files are there
        echo "Step 2: Converting text PLINK to HapMap format..."

        echo "Running: Text PLINK to HapMap conversion"
        echo "Command: ./run_pipeline.pl -plink -ped data/$TEXT_BASE_NAME.ped -map data/$TEXT_BASE_NAME.map -export data/${BASE_NAME}_hapmap -exportType Hapmap"

        docker container run --rm \
            --mount type=bind,src="$OUTPUT_DIR",dst="/workspace/program/tassel/production/data/" \
            tassel:dev \
            ./run_pipeline.pl -plink -ped data/$TEXT_BASE_NAME.ped -map data/$TEXT_BASE_NAME.map -export data/${BASE_NAME}_hapmap -exportType Hapmap

        echo "✓ Text PLINK to HapMap conversion completed successfully!"
        echo ""

        echo "=== Mixed Workflow Complete! ==="
        echo "Binary PLINK → Text PLINK → HapMap conversion completed successfully!"
        echo ""
        echo "Generated files:"
        ls -la "$OUTPUT_DIR"
        echo ""
        echo "🎉 Mixed workflow data conversion completed successfully!"
        exit 0
    else
        echo "Error: Mixed workflow only supports binary PLINK to HapMap conversion"
        exit 1
    fi
fi

# Handle TASSEL workflow (HapMap conversions)
if [[ "$TOOL" == "tassel" ]]; then

    # Text PLINK to HapMap conversion
    if [[ "$INPUT_FORMAT" == "text" && "$TARGET_FORMAT" == "hapmap" ]]; then
        echo "=== Converting Text PLINK to HapMap format using TASSEL ==="

        run_tassel_command \
            "./run_pipeline.pl -plink -ped data/$BASE_NAME.ped -map data/$BASE_NAME.map -export data/converted-datasets/$BASE_NAME -exportType Hapmap" \
            "Text PLINK to HapMap conversion"

    # HapMap to other formats conversion
    elif [[ "$INPUT_FORMAT" == "hapmap" ]]; then
        echo "=== Converting HapMap to $TARGET_FORMAT format using TASSEL ==="

        case "$TARGET_FORMAT" in
            "vcf")
                run_tassel_command \
                    "./run_pipeline.pl -h data/$BASE_NAME.hmp.txt -export data/converted-datasets/${BASE_NAME}_vcf -exportType VCF" \
                    "HapMap to VCF conversion"
                ;;
            "binary")
                run_tassel_command \
                    "./run_pipeline.pl -h data/$BASE_NAME.hmp.txt -export data/converted-datasets/${BASE_NAME}_plink -exportType Plink" \
                    "HapMap to PLINK conversion"
                ;;
            "both")
                run_tassel_command \
                    "./run_pipeline.pl -h data/$BASE_NAME.hmp.txt -export data/converted-datasets/${BASE_NAME}_plink -exportType Plink && ./run_pipeline.pl -h data/$BASE_NAME.hmp.txt -export data/converted-datasets/${BASE_NAME}_vcf -exportType VCF" \
                    "HapMap to PLINK and VCF conversion"
                ;;
            *)
                echo "Error: Unsupported target format '$TARGET_FORMAT' for HapMap input with TASSEL"
                exit 1
                ;;
        esac
    else
        echo "Error: TASSEL workflow not implemented for input format '$INPUT_FORMAT' to target format '$TARGET_FORMAT'"
        exit 1
    fi

    echo "=== Conversion Complete! ==="
    echo "TASSEL conversion completed successfully!"
    echo ""
    echo "Generated files:"
    ls -la "$OUTPUT_DIR"
    echo ""
    echo "🎉 TASSEL data conversion completed successfully!"
    exit 0
fi

# PLINK workflow
# Step 1: Convert to binary format if input is text or VCF
if [[ "$INPUT_FORMAT" == "text" ]]; then
    echo "=== Step 1: Converting text PLINK to binary PLINK ==="
    BINARY_BASE_NAME="${BASE_NAME}_binary"

    run_plink_command \
        "plink --file $CONTAINER_INPUT_DIR/$BASE_NAME --make-bed --out $CONTAINER_OUTPUT_DIR/$BINARY_BASE_NAME" \
        "Text to binary PLINK conversion"
elif [[ "$INPUT_FORMAT" == "vcf" ]]; then
    echo "=== Step 1: Converting VCF to binary PLINK ==="
    BINARY_BASE_NAME="${BASE_NAME}_binary"

    run_plink_command \
        "plink --vcf $CONTAINER_INPUT_DIR/$BASE_NAME.vcf --make-bed --out $CONTAINER_OUTPUT_DIR/$BINARY_BASE_NAME" \
        "VCF to binary PLINK conversion"
else
    # If input is already binary, just use the original base name
    BINARY_BASE_NAME="$BASE_NAME"
    echo "Input is already in binary format, skipping conversion to binary."
    echo ""
fi

# Step 2: Convert to target formats (skip if target is binary and we just created binary)
if [[ "$TARGET_FORMAT" == "binary" ]]; then
    echo "=== Conversion Complete! ==="
    echo "Binary PLINK files created successfully!"
    echo ""
elif [[ "$TARGET_FORMAT" == "text" ]]; then
    echo "=== Converting binary PLINK to text PLINK format ==="

    if [[ "$INPUT_FORMAT" == "binary" ]]; then
        # Use the original binary files from input directory
        run_plink_command \
            "plink --bfile $CONTAINER_INPUT_DIR/$BASE_NAME --recode --out $CONTAINER_OUTPUT_DIR/${BASE_NAME}_text" \
            "Binary PLINK to text PLINK conversion"
    else
        # Use the binary files we just created
        run_plink_command \
            "plink --bfile $CONTAINER_OUTPUT_DIR/$BINARY_BASE_NAME --recode --out $CONTAINER_OUTPUT_DIR/${BASE_NAME}_text" \
            "Binary PLINK to text PLINK conversion"
    fi
elif [[ "$TARGET_FORMAT" == "vcf" || "$TARGET_FORMAT" == "both" ]]; then
    echo "=== Converting binary PLINK to VCF format ==="

    if [[ "$INPUT_FORMAT" == "text" || "$INPUT_FORMAT" == "vcf" ]]; then
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

    if [[ "$INPUT_FORMAT" == "text" || "$INPUT_FORMAT" == "vcf" ]]; then
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

if [[ "$TARGET_FORMAT" != "binary" && "$TARGET_FORMAT" != "text" ]]; then
    echo "=== Conversion Complete! ==="
    echo "All output files have been saved to: $OUTPUT_DIR"
    echo ""
    echo "Generated files:"
    ls -la "$OUTPUT_DIR"
    echo ""
fi

echo "🎉 Data conversion completed successfully!"
