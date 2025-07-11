# GAPIT GWAS Analysis Example

This folder contains scripts and instructions to perform GWAS analysis using GAPIT within a Docker environment, as part of the GWASDock toolkit.

## Contents

- `scripts/`  
  - `setup_gapit_gwasdock.sh` — This script clones the repository, builds the Docker image, and runs the GAPIT container.  

- `input/`   
  - This folder contains only the converted phenotype file `TSLL.txt`, formatted for GAPIT's requirements.
  - Following the instructions in the main [README.md](../README.md) to download the phenotype file (`GSTP011.pheno`). Convert it to the GAPIT-compatible format using:  

    ```bash
    awk 'BEGIN {print "<Trait>\tTSLL"} NR>1 {print $1"\t"$2}' GSTP011.pheno > TSLL.txt
    ```
  - **Note:** The genotype files are not included in this repository. Download these files as instructed in the main [README.md](../README.md).

- `output/`  
  - The directory stores the results of GAPIT GWAS analysis.


## Usage

### Step 1: Prepare Genotype Data 

The millet dataset provides genotype data in PLINK binary format (.bed, .bim, .fam). Use the `data_converter.sh` script in the [source/shell](../../../source/shell/) directory to convert this into GAPIT-compatible Hapmap format.

Ensure Docker is running. Navigate to the shell directory and execute the following command to convert the genotype data into HapMap format (.hmp.txt) :

```bash
./data_converter.sh
-i /Users/yourusername/dataset/input
-o /Users/yourusername/dataset/output 
-n 827millet 
-f binary 
-t hapmap 
```
Executing this command generates the `827millet_hapmap.hmp.txt` file, which is required for GAPIT GWAS analysis.

**Note:** Replace `/Users/yourusername/dataset/input `and `/Users/yourusername/dataset/output` with your local paths. 

### Step 2: Setup Environment and Launch Container

Navigate to the directory containing the `setup_gapit_gwasdock.sh` script and run one of the following commands to enter the GAPIT container.

```bash
bash setup_gapit_gwasdock.sh
```
or 
```bash
./setup_gapit_gwasdock.sh
```
This process clones the repository, builds the Docker image, launches a GAPIT container with mounted data directories, and opens an interactive shell inside the container for GWAS analysis.

**Note:** Modify the paths (`PROJECT_ROOT_DIR`, `LOCAL_INPUT_DIR`,`LOCAL_OUTPUT_DIR`, `LOCAL_SCRIPTS_DIR`)  in the script to match your local directory structure.

### Step 3: Convert Genotype Data 

Run the following command to convert the HapMap format genotype file (.hmp.txt) into a numeric format (.GM, .GD) suitable for analysis:
```bash
Rscript data_conversion.R
```
This process takes `827millet_hapmap.hmp.txt` as input and generates two files: `GAPIT.Genotype.map.txt` and  `GAPIT.Genotype.Numerical.txt`.

Converting Genotype data from HapMap format to numeric (GD, GM) enhances analysis efficiency and reduces memory usage, enabling faster processing of the large dataset.

### Step 3: Run GWAS Analysis

Run the GWAS analysis using:
```bash
Rscript run_gapit_gwas.R
```
This will generate the results file `GAPIT.Association.GWAS_Results.GLM.TSLL.csv`.

### Step 4: Review Results

Results are saved in the `output/` directory.

- `GAPIT.Association.GWAS_Results.GLM.TSLL.csv`: Contains comprehensivew GWAS analysis results.

Please verify the output files to confirm the analysis completed successfully.


## Additional Notes

- Ensure Docker is installed and running before starting.
- Confirm input files are in the correct format.
  - The phenotype file should be tab-delimited with column headers: `<Trait> PhenoValue`
  - The genotype file should be in HapMap format (.hmp.txt).
