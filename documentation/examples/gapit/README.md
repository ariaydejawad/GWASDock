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

The millet dataset provides genotype data in PLINK binary format (.bed, .bim, .fam). To obtain genotype data in HapMap format (`millet.hmp.txt`), follow the instructions from Step 1 to Step 3 in the README.md located in the TASSEL subdirectory, which is at the same directory level as GAPIT.

### Step 2: Set Up Environment and Start Container
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
This process takes `Millet.hmp.txt` as input and generates two files: `GAPIT.Genotype.map.txt` and  `GAPIT.Genotype.Numerical.txt`.

Converting Genotype data from HapMap format to numeric (GD, GM) enhances analysis efficiency and reduces memory usage, enabling faster processing of the large dataset.

### Step 3: Run GWAS Analysis

Run the GWAS analysis using:
```bash
Rscript run_gapit_gwas.R
```
This will generate the results file `GAPIT.Association.GWAS_Results.GLM.Pheno(NYC).csv` in the `output/` directory.

### Step 4: Review Results

Results are saved in the `output/` directory.

- `GAPIT.Association.GWAS_Results.GLM.Pheno(NYC).csv`: Contains comprehensivew GWAS analysis results.

Please verify the output files to confirm the analysis completed successfully.


## Additional Notes

- Ensure Docker is installed and running before starting.
- Confirm input files are in the correct format.
  - The phenotype file should be tab-delimited with column headers: `<Trait> PhenoValue`
  - The genotype file should be in HapMap format (.hmp.txt).
