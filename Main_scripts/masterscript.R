##############################################################
#### Master script for collider within gridworld project #####
##############################################################

# setwd("/Users/stephaniedroop/Documents/GitHub/gw/Collider/Main_scripts")

library(tidyverse)
library(ggnewscale) # Download these if you don't have them
rm(list=ls())

#------- 1. Create parameters, run cesm, get model predictions and save them ------------
source('set_params.R')
source('get_model_preds.R') # Takes the probability vectors of settings of the variables from `set_params.R`. 
# Also loads source file `functions.R` for 3 static functions which 1) generate world settings then 
# model predictions for those and normalise/condition for unobserved variables
# we also might want a way to allocate 'RealLatent' to those worlds that have >1 unobserved rows. 
# For now we do it manually later but might want to rerun at end. See notes in 'functions.R'
source('modpred_processing.R') # Takes model predictions `all.csv` and processes to now called `tidied_preds.csv`
#source('check_preds_plot.R') # this not totally ready yet as might not need those plots anyway

#--------------- 2. Get ppt data  -------------------
source('mainbatch_preprocessing.R') # saves data
# Setwd back again - it might still be in the previous script's one 
# (which it needed there to use a nifty one line to get the data docs out and together)
setwd("../Main_scripts")

# -------------- 3. Combine model with ppt data ---------------
source('combine_ppt_with_preds.R') 
# This now a top level shell to call `combine_per_s.Rmd` to generate and plot the ppt data against each s value separately.
# Inputs: `tidied_preds.csv`, `Data.rdata` for model predictions and participant data respectively. 
# 

# Thing is....

# The model doesn't fit the ppts very well.

# Perhaps people find it too hard to be doing the calculations the full cesm would say they are?
# It is basically made up of 3 different 'sections': the cesm itself, the actual causation part, and the bayesian inference over unobserved variables
# Let us lesion the model in different ways to isolate these and combine them in different ways.


# The actual causation part is easy to remove: it is a few lines in the model processing, so just run without them
source('modpred_process_noactual.R')

# Then fit ppts data.
# Also fit to the 4-way chance model run


source('combine_summary_plots.Rmd') 
# summarises the RealLatent and SelectA vars, to show plots of proportions choosing Real Latent and A
# Haven't done a .R version to save any plots... should I?

# --------------- 4. Assess model fit to ppt data --------------
# Facet plots for each condition showing dots against coloured bars -- (this not working since redoing everything Oct24)
# source('plot_model_to_ppt.R')



# TO DO Neil meeting Oct 3
# type level is experientially what you could learn from repeated observation of the same system
# participants got each varied each time. parameters were subsampled
# token level is what I call worlds, what happened each time


# TO DO
# get cor on facet level

# I am saying the logical structre of the word form gives a different status to observed and unobvserved vars
# This puts us back in Icard's territory, so we need to test that formalism to see if that does better than Tadeg's
# wait til we have the descriptives and have articulated the worst situations, and why we think people chose these
# Find model implementation - the way they do sufficiency is inadequate and ad hoc

# WE could also softmax the model preds, to put it into a decision layer, but it might not help. so maybe no need
# In an ideal world we would fit those paramters but no need really

# sanity check the model predictions from tadeg and tobi's results, should be able to back up with theory
# Then get other model predictions
# (eg I propose people just go on heuristic of seeing the biggest number)

# we have found explnations for token outcomes when the mechanism is given. people cite unobserved vars - not handled well in co sci so far
# compare with tia's most recent cogsci paper which is type not toke, how vars combine to produce outcome 
# (they give a mechanistic explantion because they dont give them a theory)
# different from structure inference ('we posit the chef needed to make both dishes well')
