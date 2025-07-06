# PLINK GWAS Analysis Example

This folder contains scripts and instructions to perform GWAS analysis using PLINK within a Docker environment, as part of the GWASDock toolkit.

## Contents

- `scripts/`  
  - `setup_plink_gwasdock.sh` — Script to clone the repository, build the Docker image, and run the container.  

- `input/`  
  - This folder contains only the phenotype file `phenotype.txt`.  
  - Following the instructions in the main [README.md](../README.md) to download the phenotype file (`GSTP011.pheno`). Convert it to the PLINK-compatible format using:  
    ```bash
    (echo -e "FID\tIID\tTSLL"; awk 'BEGIN{OFS="\t"} NR>1{print $1, $1, $2}' GSTP011.pheno) > phenotype.txt
    ```
  - **Note:** The genotype files are not included in this repository. Download these files as instructed in the main [README.md](../README.md). 

- `output/`  
  - The directory stores the results of PLINK GWAS analysis.


## Usage

### Step 1: Set Up Environment and Start Container

```bash
bash setup_plink_gwasdock.sh
```
or 
```bash
./setup_plink_gwasdock.sh
```
This clones the repository, builds the Docker image, launches a PLINK container with mounted data directories, and opens an interactive shell inside the container for further analysis.

**Note:** Please modify the paths (`PROJECT_ROOT_DIR`, `LOCAL_INPUT_DIR`,`LOCAL_OUTPUT_DIR`) in the script to match your actual directory locations.

### Step 2: Run GWAS Analysis

Inside the container, run:

```bash
plink --bfile input/827millet --pheno input/phenotype.txt --pheno-name TSLL --linear --allow-no-sex --out output/PLINK_result
```
**Note:** The files above are examples; you may need to adjust them based on your actual file names.

### Step 3: Get Top20 SNPs

Execute the following command in the container to get top 20 SNPs:

```bash
(head -n 1 output/PLINK_result.assoc.linear && tail -n +2 output/PLINK_result.assoc.linear | sort -k9,9g | head -n 20) > output/PLINK_result_top20.linear
```

### Step 4: Review Results

Results are saved in the `output/` directory.

- `PLINK_result.assoc.linear`: Contains all the GWAS analysis results.
- `PLINK_result_top20.linear`: Includes top 20 SNPs with the smallest P-values.

Please verify the output files to confirm the analysis completed successfully.


## Additional Notes

- Ensure that Docker is installed and running before proceeding.
- Confirm input files are correctly formatted.
  - The phenotype file should be in PLINK format: FID IID PhenoValue
  - The genotype file should be in PLINK binary format (.bed, .bim, .fam)
  - Ensure that the .bed, .bim, and .fam files are in the same directory and have the same base name.