##############################################################
#### Master script for collider within gridworld project #####
##############################################################

# setwd("/Users/stephaniedroop/Documents/GitHub/gw/Collider/Main_scripts")

library(tidyverse)
library(ggnewscale) # Download these if you don't have them
rm(list=ls())

#------- 1. Create parameters, run cesm, get model predictions and save them ------------
source('set_params.R')
source('get_model_preds2.R') # (Made v2 to introduce sensitivity parameter)
# Takes the probability vectors of settings of the variables from `set_params.R`. 
# Also loads source file `functions.R` for 3 static functions which 1) generate world settings then 
# model predictions for those and normalise/condition for unobserved variables
# we also might want a way to allocate 'RealLatent' to those worlds that have >1 unobserved rows. 
# For now we do it manually later but might want to rerun at end. See notes in 'functions.R'

source('modpred_process_allmodules.R') 



# OLD 
#source('modpred_processing.R') # Takes model predictions `all.csv` and processes to now called `tidied_preds.csv`
# (now processing is split out to series of scripts all starting with 'modpred_process...')
#source('check_preds_plot.R') # might not need those plots

#--------------- 2. Get ppt data  -------------------
source('mainbatch_preprocessing.R') # saves data
# Setwd back again - it might still be in the previous script's one 
# (which it needed there to use a nifty one line to get the data docs out and together)
setwd("../Main_scripts")

# -------------- 3. Combine model with ppt data ---------------
source('combine_ppt_with_preds.R') 
# This now a top level shell to call `combine_per_s.Rmd` to generate and plot the ppt data against each s value separately.
# Inputs: `tidied_preds3.csv`, `Data.rdata` for model predictions and participant data respectively. 

# ------------- 4. Lesioned models ------------------
# The full model made up of 3 different 'sections': 
# 1. counterfactual simulation (the cesm itself) for testing the strength of each candidate cause
# 2. the actual causation part 
# 3. and the bayesian inference over unobserved variables
# Let us lesion the model in different ways to isolate these and combine them in different ways.

# 1. To lesion cf:
# 2. The actual causation part is easy to remove: it is a few lines in the model processing, so just run without them
source('modpred_process_noactual.R')
# 3. To lesion Bayesinf:
# 4. Direct dependency ??

# Then fit ppts data and get LL as normal
# Also fit to the 4-way chance model run


source('combine_summary_plots.Rmd') 
# summarises the RealLatent and SelectA vars, to show plots of proportions choosing Real Latent and A
# Haven't saved plots separately

# --------------- 4. Assess model fit to ppt data --------------
# Facet plots for each condition showing dots against coloured bars -- (this not working since redoing everything Oct24)
# source('plot_model_to_ppt.R')
