# TASSEL GWAS Analysis Example

This folder contains scripts and instructions to perform GWAS analysis using TASSEL within a Docker environment, as part of the GWASDock toolkit.

## Contents

- `scripts/`  
  - `setup_tassel_gwasdock.sh` — This script clones the repository, builds the Docker image, and runs the tassel container.  

- `input/`   
  - This folder contains only the converted phenotype file `TSLL.txt`, formatted for TASSEL's requirements.
 
  - Following the instructions in the main [README.md](../README.md) to download the phenotype file (`GSTP011.pheno`). Convert it to the TASSEL-compatible format using:  

    ```bash
    awk 'BEGIN {print "<Trait>\tTSLL"} NR>1 {print $1"\t"$2}' GSTP011.pheno > TSLL.txt
    ```
  - **Note:** The genotype files are not included in this repository. Download these files as instructed in the main [README.md](../README.md).

- `output/`  
  - The directory stores the results of TASSEL GWAS analysis.


## Usage

### Step 1: Prepare Genotype Data

The millet dataset provides genotype data in PLINK binary format (.bed, .bim, .fam). Use the `data_converter.sh` script in the [source/shell](../../../source/shell/) directory to convert this into TASSEL-compatible Hapmap format.

Ensure Docker is running. Navigate to the shell directory and execute the following command to convert the genotype data into HapMap format (.hmp.txt) :

```bash
./data_converter.sh
-i /Users/yourusername/dataset/input
-o /Users/yourusername/dataset/output 
-n 827millet 
-f binary 
-t hapmap 
```
Executing this command generates the `827millet_hapmap.hmp.txt` file, which is required for TASSEL GWAS analysis.

**Note:** Replace `/Users/yourusername/dataset/input `and `/Users/yourusername/dataset/output` with your local paths. 

### Step 2: Setup Environment and Launch Container
Navigate to the directory containing the `setup_tassel_gwasdock.sh` script and run one of the following commands to enter the TASSEL container.

```bash
bash setup_tassel_gwasdock.sh
```
or 
```bash
./setup_tassel_gwasdock.sh
```
This process clones the repository, builds the Docker image, launches a TASSEL container with mounted data directories, and opens an interactive shell inside the container for GWAS analysis.


**Note:** Modify the paths (`PROJECT_ROOT_DIR`, `LOCAL_INPUT_DIR`,`LOCAL_OUTPUT_DIR`)  in the script to match your local directory structure.

### Step 3:  Run GWAS Analysis 

Within the container, ensure you are in the `production` directory. If you are not, navigate to the TASSEL scripts directory `production`:
```bash
cd production
```

Run the GWAS analysis using:
```bash
./run_pipeline.pl -debug -fork1 -h ../input/827millet_hapmap.hmp.txt -fork2 -importGuess ../input/TSLL.txt -combine3 -input1 -input2 -intersect -glm -export ../output/Tassel_result.txt
```
This will generate the results file `Tassel_result1.txt` in the `output/` directory.

### Step 4: Get Top20 SNPs
To extract the top 20 SNPs with the smallest P-values, execute:

```bash
(head -n 1 ../output/Tassel_result1.txt && tail -n +2 ../output/Tassel_result1.txt | sort -k 6,6g | head -n 20) > ../output/Tassel_result_top20.txt
```
After running this command, `Tassel_result_top20.txt` will be available in the `output/` directory.

### Step 6: Review Results

Results are saved in the `output/` directory.

- `Tassel_result1.txt`: Contains comprehensivew GWAS analysis results.
- `Tassel_result_top20.txt`: Includes top 20 SNPs with the smallest P-values.

Please verify the output files to confirm the analysis completed successfully.


## Additional Notes

- Ensure Docker is installed and running before starting.
- Confirm input files are in the correct format.
  - The phenotype file should be tab-delimited with column headers: `<Trait> PhenoValue`
  - The genotype input file should be in PLINK's traditional text-based formats (.map .ped).
  - Ensure that the .map and .ped files are in the same directory and share the same base name.
