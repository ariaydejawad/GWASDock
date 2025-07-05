# Usage Examples for GWAS Analysis
This directory provides hands-on workflows for performing Genome-Wide Association Studies (GWAS) using GWASDock, our integrated multi-GWAS suite. These examples demonstrate how to achieve streamlined GWAS analysis by leveraging GWASDock to overcome the complexities of individual GWAS tool installation and environment management.

## Overview of Example Workflows
Detailed, tool-specific GWASDock example workflows for GWAS analysis are organized into subdirectories (e.g., PLINK/, GCTA/, TASSEL/, GAPIT/, and FastLMM/). Within each subdirectory, you will find specific command-line examples and instructions.


## Datasets Used

The examples in this documentation utilize the **millet dataset** for demonstration purposes.

* **Dataset Access:** The millet dataset can be accessed and downloaded from the [CropGS-Hub website](https://iagr.genomics.cn/CropGS/#/Datasets) by searching for the ID **GSTP011**.
* **Dataset Description:** This dataset comprises **827 samples** with **161,562 SNPs** and **12 different phenotypes**.
* **Selected Trait:** For the GWAS analyses presented here, we've selected the **Top Second Leaf Length (TSLL)** as the trait of interest.


### Data File Formats

The millet dataset, when prepared for GWASDock, includes the following types of data files:

* **Genotype Data:** SNP data storing individual genotype information.
    * **PLINK BED/BIM/FAM format:** A binary file system utilized for analyses with **PLINK**, **GCTA**, and **FaST-LMM**.
    * **HapMap format (.hmp.txt):** A text-based format required for analyses with **TASSEL** and **GAPIT**.
    * *Note: Conversion scripts or instructions for converting between these formats are provided in the relevant tool-specific subdirectories.*

* **Phenotype Data:** Typically a tab-separated text file (`.pheno` or `.txt`) containing columns for individual IDs (e.g., FID, IID) and the phenotype values. The specific format and required column names may vary slightly depending on the GWAS tool. Please refer to the dedicated "Phenotype File Column Descriptions" section below for detailed requirements for each tool.

### Input and Output Files for Each Tool

| GWAS     | Geno Input    | Pheno Input   | Output                                         |
| :------- | :------------ | :------------ | :--------------------------------------------- |
| PLINK    | millet.bed    | phenotype.txt | result.assoc.linear                            |
| GCTA     | millet.bed    | phenotype.txt | result.mlma                                    |
| FaST-LMM | millet.bed    | phenotype.txt | result.csv                                     |
| TASSEL   | millet.hmp.txt | TSLL.txt      | result.txt                                     |
| GAPIT    | millet.hmp.txt | TSLL.txt      | GAPIT.Association.GWAS_Results.GLM.TSLL.csv |

**Phenotype File Column Descriptions:**

*   phenotype.txt : FID, IID, TSLL
*   TSLL.txt:  <Trait>, TSLL


## Getting Started: Running the Examples

Follow these steps to execute the GWAS analysis examples provided in this repository:

1.  **Select Your Tool:** Choose the specific GWAS tool (e.g., PLINK, TASSEL) that aligns with your analysis requirements or interests.
2.  **Navigate and Review:** Enter the corresponding subdirectory for your chosen tool (e.g., `examples/PLINK/`). Carefully read the `README.md` file within that subdirectory to understand the specific usage instructions, input data requirements, and expected outputs for that particular example.
3.  **Prepare Data:**
    * **Download:** If you haven't already, download the millet dataset from the [CropGS-Hub website](https://iagr.genomics.cn/CropGS/#/Datasets) (ID: **GSTP011**).
    * **Format:** Ensure your genotype and phenotype files are in the correct format as specified in the "Data File Formats" section above.
    * **Placement:** Place the prepared example data files in the locations specified by the example code (e.g., within a `input/` folder in the tool's subdirectory, or update paths accordingly).
4.  **Execute the Container:**  Following the instructions in the tool's `README.md` (e.g.`documentation/examples/PLINK/README.md`), run the Docker container. Verify that it starts without errors and is ready for your GWAS analysis.
5.  **Execute and Analyze:** Run the provided example code (e.g., a shell script, Python (`.py`) script, R (`.R`) script, or direct command-line execution). Afterward, analyze the generated output results.

**Note:** The file paths in the example code may need to be modified according to your actual file locations.

## Contributing

You are welcome to contribute more GWAS tool example code! If you have any good example code or find any bugs, please feel free to submit a pull request.