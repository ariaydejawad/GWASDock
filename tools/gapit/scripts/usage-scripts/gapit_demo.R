library(GAPIT)

# Import data from Z. Zhang Lab
myY <- read.table("http://zzlab.net/GAPIT/data/mdp_traits.txt", head = TRUE)
myGD = read.table(file = "http://zzlab.net/GAPIT/data/mdp_numeric.txt", head = T)
myGM = read.table(file = "http://zzlab.net/GAPIT/data/mdp_SNP_information.txt", head = T)

# Perform a Genome-Wide Association Study on 'toy' data
myGAPIT = GAPIT(Y = myY[,c(1,2,3)], GD = myGD, GM = myGM, PCA.total = 3, model = c("FarmCPU", "BLINK"), Multiple_analysis = TRUE)
