#source("http://zzlab.net/GAPIT/gapit_functions.txt")
library(GAPIT)


myG <- read.delim("millet.hmp.txt", head = FALSE) 
myGAPIT <- GAPIT(G=myG, output.numerical=TRUE) 
myGD= myGAPIT$GD
myGM= myGAPIT$GM