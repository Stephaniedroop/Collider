#######################################################################
##########################   GRIDWORLD  ###############################
# Implementation of Quillien Lucas 2020/2022 CESM

# Takes the 64 combinations of factors defined in 'worldsetup.R', 
# weighted by beta slope parameters obtained from behavioural experiment and saved as 
# pChoice df via worlds.rdata, and runs counterfactual model on them.

# This is a minimal version to see how CESM works. It does not save predictions.
# Later, see 'ecesm_model_preds.R' to run with range of s params 0.05-0.95, saving model predictions.
# Then, to fit to behavioural data, go to script 'CESM_fit.R' although this still under pilot. 

# ------------------ Prelims ------------------------------
library(tidyverse)
library(ggplot2)
rm(list=ls())

load('worlds.rdata', verbose = T) # 64 obs of 10 vars

causes <- c('Preference','Knowledge','Character','Start')

# ---------------- CESM ----------------------------------

N_cf <- 1000 # How many counterfactual samples to draw. Change this to fewer for speed
s <- .7 # Set it to whatever for playing; optimise later

#Loop through cases
for (c_ix in 1:64)
{
  #The current case
  case <- pChoice[c_ix,]
  # Empty df of N obs (eg 1000) of 7 vars, to put generated counterfactual setting in
  cfs <- data.frame(Preference = rep(NA, N_cf),
                  Knowledge = rep(NA, N_cf),
                  Character = rep(NA, N_cf),
                  Start = rep(NA, N_cf),
                  
                  Path = rep(NA, N_cf),
                  Choice = rep(NA, N_cf),
                  
                  Match = rep(NA, N_cf))
  # Generate N counterfactuals
  for (i in 1:N_cf)
  {
    cf_cs <- as.numeric(case[1:4]) # Set of 4 causes biased to actual world
    #Start with the actual world and jiggle them with probability 1-s, gives vector of 4 booleans
    flip <- runif(4)>s 
    cf_cs[flip] <- 3-as.numeric(cf_cs[flip]) # Switches 1s to 2s and 2s to 1s for the flipped cases
    
    #Pull out the corresponding four outcomes (to see their probabilities) 4 obs of 10 vars
    cf_cases <- pChoice %>% filter(as.numeric(Preference)==cf_cs[1],
                                as.numeric(Knowledge)==cf_cs[2],
                                as.numeric(Character)==cf_cs[3],
                                as.numeric(Start)==cf_cs[4])
    
    #Sample one outcome according to its probability
    cf_out_ix <- sample(x=1:4, size = 1, p=cf_cases$p_action)

    cf <- cf_cases[cf_out_ix,1:6] 
    
    # Check if it (exactly) matches the true outcome; adds column T/F
    cf$Match = cf$Choice==case$Choice & cf$Path==case$Path
    # Add the current now-finished case of N to the collection of cfs
    cfs[i,] <- cf
  }
  
  # Now calculate how much the effect depends (directly) on each cause across these counterfactual worlds
  cor_sizes <- rep(NA, 4)
  for (cause in 1:4)
  {
    # Across the counterfactuals how much more common is the outcome with vs without each factor
    cor_sizes[cause] <- cor(cfs[[causes[cause]]], cfs$Match) * (c(-1,1)[as.numeric(case[[causes[cause]]])])
  }
  cat(c_ix, cor_sizes, '\n')
}

