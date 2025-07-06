source("http://zzlab.net/GAPIT/gapit_functions.txt")

# Read phenotype and genotype data
myY <- read.table("TSLL.txt", header = TRUE, sep = "\t")

myGD <- read.table("GAPIT.Genotype.Numerical.txt", header=TRUE)

myGM <- read.table("GAPIT.Genotype.map.txt", header=TRUE)

myGAPIT <- GAPIT(
  Y = myY,
  GD = myGD,          
  GM = myGM,
  PCA.total = 0,
  model = "GLM",
  file.output = TRUE
  #SNP.MAF = 0.2,
  #SNP.impute = "Major",    # Imputation method
)

# Check GAPIT output
print("GAPIT object:")
print(names(myGAPIT))
