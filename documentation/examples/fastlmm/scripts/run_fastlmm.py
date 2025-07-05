import logging
import pandas as pd
from fastlmm.association import single_snp
from pysnptools.snpreader import Bed
import os
import time
start_time = time.time()

logging.basicConfig(level=logging.INFO)

# The input directory should contain the phenotype file (phenotype.txt) and the genotype files (.bed, .bim, .fam).
# The output directory will be used to save the results.
inputdir = "/workspace/program/fast-lmm/input"
if not os.path.exists(inputdir):
    logging.error(f"Input directory not found: {inputdir}")
    exit()

output_dir = "/workspace/program/fast-lmm/output"
if not os.path.exists(output_dir):
    logging.error(f"Output directory not found: {output_dir}")
    exit()


# The files below are examples; you may need to adjust them based on your actual file locations and names.
# The phenotype file should be in PLINK format: FID IID PhenoValue
# The genotype file should be in PLINK binary format (.bed, .bim, .fam)
# The .bed file is the main file, while .bim and .fam files are metadata files that describe the SNPs and samples, respectively.
# Ensure that the .bed, .bim, and .fam files are in the same directory and have the same base name.

pheno_fn = os.path.join(inputdir, "phenotype.txt")          
test_snps = os.path.join(inputdir, "827millet.bed")

# Check Phenotype file and genotype file
if not os.path.exists(pheno_fn):
    logging.error(f"Phenoytpe file not found: {pheno_fn}")
    exit()
if not os.path.exists(test_snps):
    logging.error(f"Genotype file (.bed) not found: {test_snps}")
    base_name = os.path.splitext(test_snps)[0]
    if not os.path.exists(base_name + ".bim"):
        logging.warning(f"Genotype file (.bim) not found: {base_name}.bim")
    if not os.path.exists(base_name + ".fam"):
         logging.warning(f"Genotype file (.fam) not found: {base_name}.fam")
    exit()

logging.info(f"Using phenotype file: {pheno_fn}")
logging.info(f"Using genotype file: {test_snps}")

# Run single_snp association analysis
try:
    results_dataframe = single_snp(test_snps=test_snps, pheno=pheno_fn, count_A1=False)

    if results_dataframe.empty:
        logging.warning("Analysis completed, but the results are empty. Please check input file formats and data consistency")
    else:
        # Print result of the first SNP
        print("--- Example Analysis Result ---")
        print(f" SNP ID: {results_dataframe.iloc[0].SNP}")
        print(f" P-value: {results_dataframe.iloc[0].PValue:.7g}") 
        print(f" Total number of SNPs analyzed: {len(results_dataframe)}")

        # Save results to a CSV file
        output_file = os.path.join(output_dir, "Fastlmm_result.csv")        
        logging.info(f"Saving results to: {output_file}")
        results_dataframe.to_csv(output_file, index=False, sep='\t')

        # Save top 20 SNPs with the smallest P-values
        top20_file = "/workspace/program/fast-lmm/output/Fastlmm_result_top20.csv"
        top20_df = results_dataframe.sort_values(by="PValue").head(20)
        logging.info(f"Save top 20 SNPs with the smallest P-values to: {top20_file}")
        top20_df.to_csv(top20_file, index=False, sep='\t')
except Exception as e:
    logging.error(f"Error during execution: {e}")
    logging.error("Please check the following:")
    logging.error("1. Are the file paths correct?")
    logging.error("2. Is phenotype.txt in proper PLINK phenotype format (FID IID PhenoValue)?")
    logging.error("3. Are .bed, .bim, .fam valid PLINK binary files?")
    logging.error("4. Do the FID and IID in the phenotype file match those in the .fam file?")
    logging.error("5. Is there enough memory to handle the dataset?")

# Calculate and print the total runtime
runtime = time.time() - start_time  # Calculate total runtime
print(f"Total Run Time： {runtime} seconds")


