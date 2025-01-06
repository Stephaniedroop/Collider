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
s_vals <- c(seq(0.6, 0.95, 0.05), seq(0.96, 0.99, 0.01)) # The old way was 0-1 but model fit was better towards the higher end so I redid just for that - redo if need
sens_vals <- seq(0.00, 1.00, 0.05)
modelruns <- 10

load('../model_data/params.rdata', verbose = T) # defined in script `set_params.r`

# Load functions: world_combos, get_cond_probs, get_dd, get_cfs 
source('functions.R')

set.seed(12)

# -------------- Full cesm - what we started with ----------

# Empty df to put everything in
all <- data.frame(matrix(ncol=19, nrow = 0))
alldd <- data.frame(matrix(ncol=12, nrow = 0)) # is this the right number of cols? For now

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
  ddd <- get_dd(params = poss_params[[i]], structure = 'disjunctive', df = newdfd)
  ddd$pgroup <- i
  ddc <- get_dd(params = poss_params[[i]], structure = 'conjunctive', df = newdfc)
  ddc$pgroup <- i
  alldd <- rbind(alldd, ddd, ddc) 
  # 3) Get predictions of the counterfactual effect size model for all these worlds AND S ((((AND SENS!!! TO DO FIRST THING))))
  for (s in 1:length(s_vals)) {
    allmd <- data.frame(matrix(ncol = 14, nrow = 0))
    for (t in 1:length(sens_vals)) {
      mp1 <- data.frame(matrix(ncol = 14, nrow = 0))
      #mp1c <- data.frame(matrix(ncol = 14, nrow = 0))
      # We also want to calculate like 10 versions to get the variance of model predictions
      for (m in 1:modelruns) {
        mpd <- get_cfs(params = poss_params[[i]], structure = 'disjunctive', df = dfd, s = s_vals[s], sens = sens_vals[t]) # 16 obs of 6
        mpd$run <- m
        mpc <- get_cfs(params = poss_params[[i]], structure = 'conjunctive', df = dfc, s = s_vals[s], sens = sens_vals[t])
        mpc$run <- m
        mp1 <- rbind(mp1, mpd, mpc)
        #mp1c <- rbind(mp1c, mpc)
      }
      allm <- rbind(allm, mp1)
     }
     mp1d$pgroup <- i
     mp1c$pgroup <- i
     # Put them together, to get the var values
     d <- merge(x = mp1d, y = newdfd, by = c('index')) 
     c <- merge(x = mp1c, y = newdfc, by = c('index'))
     all1 <- rbind(d,c) # next, how to rbind all to the same all
     all <- rbind(all, all1) # 20160 obs of 24 now 26880 of 24 
   }
} 
# It takes a minute or two but not terrible.
# saves intermediate set of world setup and model predictions
write.csv(all, "../model_data/allnew.csv")
write.csv(alldd, "../model_data/alldd.csv")

# Standalone direct dependence model predictions, same as stability = 1
# can do it by hand, no simulation for the 1111 conj: because changing any var is fully determinative of effect not occurring. In 1111 dis everything is 0.
# - this option should make predictions like 'two options are equally good'





# These model predictions are raw and do not account for some variables being unobserved.
# Now treat them for actual causality and unobservability in script `modpred_processing.R`

# -------------- Others, lesioned ------------------

# 1. Run model again with chance params to see if people are better modelled with no probabilities.
# 2. Noactual - in a processing script, then fit in 20x .Rmd as before
# 3. For various lesions of the cp: Can probably be done in the data later also, as we only calculate the raw cesm then treat it later