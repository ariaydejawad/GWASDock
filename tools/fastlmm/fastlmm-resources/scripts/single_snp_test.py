import logging
from fastlmm.association import single_snp
from fastlmm.util import example_file
from pysnptools.snpreader import Bed

logging.basicConfig(level=logging.INFO)

pheno_fn = example_file("fastlmm/feature_selection/examples/toydata.phe")
test_snps = example_file("fastlmm/feature_selection/examples/toydata.5chrom.*", "*.bed")
results_dataframe = single_snp(test_snps=test_snps, pheno=pheno_fn, count_A1 = False)
print(results_dataframe.iloc[0].SNP, round(results_dataframe.iloc[0].PValue, 7), len(results_dataframe))
