#################################################### 
###### Collider - assess model fit       #####
####################################################

# Script to calculate correlations then plot a scatter plot


# we can check the raw correlation as a first metric of fit i.e. most simply just cor(count, model_predicted_probability) 
# for all the data ignoring which condition it comes from.  
# You could also make a scatter plot of count by model predicted probability 
# (maybe keeping colour aesthetic as you have it and maybe adding shape to denote which of the 7 scenarios its from

#library(tidyverse)
rm(list=ls())

load('../processed_data/fp.rdata', verbose = T) # saved in `collider_analysis.R`


# Put all the two threes  fp ('for plotting') back together again
fpd <- rbind(fp1d, fp2d, fp3d) # 168 obs of 6 vars
fpc <- rbind(fp1c, fp2c, fp3c) # 120 obs of 6

# Now plot scatter 

pd <- ggplot(fpd, aes(x = prop, y = pred, shape = trialtype, color = node3)) +
  geom_point(aes(shape = trialtype, color = node3)) +
  theme_bw() +
  guides(shape = guide_legend(override.aes = list(size = 5) ) ) # Makes key symbols bigger

pd

pc <- ggplot(fpc, aes(x = prop, y = pred, shape = trialtype, color = node3)) +
  geom_point(aes(shape = trialtype, color = node3)) +
  theme_bw() +
  guides(shape = guide_legend(override.aes = list(size = 5) ) ) # Makes key symbols bigger

pc
