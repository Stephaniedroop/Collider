#################################################### 
###### Collider - get model predictions  #####
####################################################
# Script to set up probability vectors of each variable, then run a series of 3 source files to implement the cesm
# and save the model predictions for each run

rm(list=ls())
setwd("../Main_scripts")
library(tidyverse)

#library(profvis)

# Other values set outside for now 
N_cf <- 10000L # How many counterfactual samples to draw
s_vals <- c(seq(0.00, 0.95, 0.05), seq(0.96, 0.99, 0.01)) # The old way was just the first seq - redo if need
modelruns <- 10

load('../model_data/params.rdata', verbose = T) # defined in script `set_params.r`

# Load functions: world_combos, get_cond_probs, generic_cesm 
source('functions.R')


# -------------- Full cesm - what we started with ----------

# Empty df to put everything in
all <- data.frame(matrix(ncol=18, nrow = 0))

# For each setting of possible probability parameters we want to: 
# 1) generate worlds, 2) get conditional probabilities and 3) get model predictions
for (i in 1:length(poss_params)) { 
  # 1) Get possible world combos of two observed variables in both dis and conj structures
  dfd <- world_combos(params = poss_params[[i]], structure = 'disjunctive')
  dfd$pgroup <- i
  dfc <- world_combos(params = poss_params[[i]], structure = 'conjunctive')
  dfc$pgroup <- i
  # 2) Get conditional probabilities of these and the two unobserved variables too
  newdfd <- get_cond_probs(dfd)
  newdfc <- get_cond_probs(dfc)
  # 2.5) Get direct dependency of each var (ie stability = 1)
  
  # 3) Get predictions of the counterfactual effect size model for all these worlds AND S
  for (s in 1:length(s_vals)) {
    mp1d <- data.frame(matrix(ncol = 14, nrow = 0))
    mp1c <- data.frame(matrix(ncol = 14, nrow = 0))
    # We also want to calculate like 10 versions to get the variance of model predictions
    for (m in 1:modelruns) {
      mpd <- get_cfs(params = poss_params[[i]], structure = 'disjunctive', df = dfd, s = s_vals[s]) # 16 obs of 6
      mpd$run <- m
      mpc <- get_cfs(params = poss_params[[i]], structure = 'conjunctive', df = dfc, s = s_vals[s])
      mpc$run <- m
      mp1d <- rbind(mp1d, mpd)
      mp1c <- rbind(mp1c, mpc)
    }
    mp1d$pgroup <- i
    mp1c$pgroup <- i
    # Put them together a bit scrappily; we'll tidy it later
    d <- merge(x = mp1d, y = newdfd, by = c('index')) 
    c <- merge(x = mp1c, y = newdfc, by = c('index'))
    all1 <- rbind(d,c) # next, how to rbind all to the same all
    all <- rbind(all, all1) # 20160 obs of 24 now 26880 of 24 
  }
} 
# It takes a minute or two but not terrible.
# saves intermediate set of world setup and model predictions
write.csv(all, "../model_data/all.csv")

# Standalone direct dependence model predictions, same as stability = 1
# can do it by hand, no simulation for the 1111 conj: because changing any var is fully determinative of effect not occurring. In 1111 dis everything is 0.
# - this option should make predictions like 'two options are equally good'





# These model predictions are raw and do not account for some variables being unobserved.
# Now treat them for actual causality and unobservability in script `modpred_processing.R`

# -------------- Others, lesioned ------------------

# 1. Run model again with chance params to see if people are better modelled with no probabilities.
# 2. Noactual - in a processing script, then fit in 20x .Rmd as before
# 3. For various lesions of the cp: Can probably be done in the data later also, as we only calculate the raw cesm then treat it later