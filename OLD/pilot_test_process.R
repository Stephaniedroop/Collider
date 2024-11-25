#################################################### 
###########  Collider analysis pilot   #############
####################################################

# Script for the first, messy, five ppts before I tweaked the experiment to correct format. 
# ie different preprocessing script than for the others
# This script makes a single df of all the ppts, which was then reduced and tidied in excel to be the right format
# Then saved again as 'pilot1.csv'
# DO NOT USE THIS AGAIN

library(tidyverse)
rm(list=ls())

# Setwd 
setwd("/Users/stephaniedroop/Documents/Gridworld/collider/pilotdata")

# read in csvs
csvList <- lapply(list.files("./"), read.csv, stringsAsFactors = F)
# bind them 
dataset <- do.call(rbind, csvList) # 

# save as csv outside cos this is too complicated
write.csv(dataset, 'pilot.csv')

