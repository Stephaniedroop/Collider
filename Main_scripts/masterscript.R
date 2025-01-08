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

# Process model predictions to be more user friendly: part 1 (more later, when combining with participant data)
# Wrangles and renames variables, splits out node values 0 and 1, saves .rdata for each value of stability parameter s
source('modpred_processing1.R') 

#--------------- 2. Get ppt data  -------------------
source('mainbatch_preprocessing.R') # saves data
# Setwd back again - it might still be in the previous script's one 
# (which it needed there to use a nifty one line to get the data docs out and together)
setwd("../Main_scripts")

# -------------- 3. Combine model with ppt data ---------------
source('combine_ppt_with_preds.R') 
# This now a top level shell to call 
# 1) `combine_per_s.R` to combine participant and model predictions separately for each value of s
# 2) `visualise_per_s.Rmd` to generate and plot the ppt data against each s value separately 
# (html output saved as '../processed_data/[s]_report.html')

source('combine_summary_plots.Rmd') 
# summarises the RealLatent and SelectA vars, to show plots of proportions choosing Real Latent and A, used in lab presentation
# Haven't saved plots separately. Non-core.

source('loglik_heatmap.Rmd') # Generates a heatmap to show which combination of parameters give best log likelihood 
# s=0.9, sens=0, ll=-2716
# s=0.96, sense=0.05, ll=-2711 - or 0.99-0.85--2537 when reran but not removed IsPerm filter or -2934 when removed
# or 
# (The simplest baseline is log(1/8)*3408 = -7086)
# One other possible baseline is log(0.25)*568+log(0.5)*2840 = -2755 (ie for the permissable, coherent answers)
# But then I reran for not manually setting Actual cause, and without filtering out the non Permissable answers, and got better:
# NoAct, s=0.35, sens=0.3, -1277


# Not sure what needs to be recombined, to get model fit of lesions.

# ------------- 4. Lesioned models ------------------
# The full model made up of 3 different 'sections': 
# 1. counterfactual simulation (the cesm itself) for testing the strength of each candidate cause
# 2. the actual causation part 
# 3. and the bayesian inference over unobserved variables
# Let us lesion the model in different ways to isolate these, and reassess model fit.

# 1. To lesion cf we could just sample from the actual causes. What involved in this? Getting non0 and just picking one?
# 2. The actual causation part is easy to remove: it is a few lines in the model processing, so just run without them.
source('combine_ppt_with_preds_noact.R') # ie once again, highlevel top to run combine_per_s_noact.R and visualise_per_s_noact.Rmd
source('loglik_heatmap_noact.Rmd')



# 3. To lesion Bayesinf:
# Need separate script, probable `lesions.Rmd`
source('lesions.Rmd') # Not done yet
# 4. Direct dependency ??
source('modpred_process_dd_all.R') # TO DO 
# Then fit ppts data and get LL as normal
# Also fit to the 4-way chance model run

# ----------- 5. Other, non-core ---------------------


# --------------- 4. Assess model fit to ppt data --------------
# Facet plots for each condition showing dots against coloured bars -- (this not working since redoing everything Oct24)
# source('plot_model_to_ppt.R')
