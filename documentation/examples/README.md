# Examples of GWAS Analysis Using GWASDock
This directory offers **hands-on workflows** for performing Genome-Wide Association Studies (GWAS) using **GWASDock**, our integrated multi-GWAS suite. These examples using **Millet dataset** demonstrate how to **streamline your GWAS analysis** by leveraging GWASDock to overcome the complexities of individual GWAS tool installation and environment management.

## Workflow Overview
Explore **detailed, tool-specific GWASDock example workflows** for GWAS analysis, organized into subdirectories (e.g., `example/plink/`, `example/gcta/`, `example/tassel/`, `example/gapit/`, and `example/fastlmm/`).

Within each subdirectory, you'll find a **comprehensive demonstration of GWAS Analysis** using the respective tool. This includes **essential steps** like:

* **Preparing the input phenotype file**
* **Genotype data format conversion** (if necessary)
* **Automating container setup and execution**
* **Running the GWAS code**
* **Presenting the output results**

## Dataset
The examples in this documentation utilize the **millet dataset** for demonstration purposes.

* **Dataset Access:** Download the **millet dataset** from the [CropGS-Hub website](https://iagr.genomics.cn/CropGS/#/Datasets) by searching for the ID **GSTP011**. This dataset includes **827 samples** with **161,562 SNPs** and **12 different phenotypes**. For these examples, we use the **Top Second Leaf Length (TSLL)** trait.
* **Data File Formats:** 
  - **Genotype Data**
    * **PLINK BED/BIM/FAM** for **PLINK**, **GCTA**, and **FaST-LMM**.
    * **HapMap format (.hmp.txt)** for **TASSEL** and **GAPIT**.

    **Note**: Format conversion scripts and instructions are available in the respective tool subdirectories (e.g., `examples/PLINK/README.md`).

  - **Phenotype Data:** 
    Typically a tab-separated text file (`.pheno` or `.txt`) containing columns for individual IDs (e.g., FID, IID) and the phenotype values. The specific format and required column names may vary slightly depending on the GWAS tool. 

* **Input and Output Files for Each Tool** 

    | GWAS     | Geno Input    | Pheno Input   | Output                                         |
    | :------- | :------------ | :------------ | :--------------------------------------------- |
    | PLINK    | millet.bed    | phenotype.txt | PLINK_result.assoc.linear                            |
    | GCTA     | millet.bed    | phenotype.txt | GCTA_result.mlma                                    |
    | FaST-LMM | millet.bed    | phenotype.txt | Fastlmm_result.csv                                     |
    | TASSEL   | millet.hmp.txt | TSLL.txt      | Tassel_result.txt                                     |
    | GAPIT    | millet.hmp.txt | TSLL.txt      | GAPIT.Association.GWAS_Results.GLM.TSLL.csv |

## Getting Started: Running the Examples

Follow these steps to execute the GWAS analysis examples provided in this repository:

1.  **Select Your Tool:** Choose the specific GWAS tools (e.g., PLINK, TASSEL) that aligns with your analysis requirements or interests.

2.  **Navigate and Review:** Enter the corresponding subdirectory for your chosen tool (e.g., `examples/PLINK/`). Carefully read the `README.md` file within that subdirectory to get a comprehensive demonstration of GWAS using the tool, including essential steps such as preparing the input phenotype file, data conversion if necessary, automating the run of the GCTA Container, executing the GWAS code, and presenting the output results.

4.  **Run the tool Container:**  Refer to the `README.md` file located in the corresponding subdirectory (e.g., documentation/examples/PLINK/README.md) for instructions on how to automate setup and run its Docker container. This step often includes mounting local data paths.
**Note:** The local data paths in the script may need to be modified according to your actual file locations.

5.  **GWAS Analysis:** Execute the provided example code, which could be a shell script, Python (`.py`) script, R (`.R`) script, or a direct command-line execution to complete the GWAS analysis. To verify the correctness of the execution, you can compare your generated result file with the provided output file.
**Note:** You can adjust the execution parameters as needed.

## Contributing

You are welcome to contribute more GWAS tool example code! If you have any good example code or find any bugs, please feel free to submit a pull request.