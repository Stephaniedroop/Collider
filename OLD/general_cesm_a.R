##################################################################
################### GW - general CESM ############################

# A script to run counterfactual simulation and assign a quantity of responsibility to each of several causes.
# Takes form of a big function that calculates all possible observations of the causes ('worlds').
# Then simulates counterfactuals by resampling from the prior for vars with p=1-s where s=stability to real world.
# Then prints out correlation of effect with each causal variable across these simulated counterfactual worlds.

# This is script 1/3, in a series where 2) is `unobs.r`, 3) is `collider_plot.r`

# Needs inputs of:
# 1) cause variables, assuming these happen either 0,1 and their strengths, assuming in a vector of prob 0, prob 1
# 2) causal structure, whether disjunctive or conjunctive

# NOW AFTER TADEG'S HALPERN ACTUAL CAUSATION POINT, THIS IS VERSION..._a WHERE WE WEED OUT OBVIOUS NON-CAUSES

# ------- Prelims -----------
# library(tidyverse)
# rm(list=ls())

# ----------- Define an example prior df -------------------------
# Here define two causal vars and an exogenous noise variable for each (i.e. var epsilon A goes with A)
# Change these values manually and rerun the series of 3 scripts. Just keep a note of what params
# pA <- c(0.9,0.1) # 
# peA <- c(0,1) #... most of the time the noise var for a doesn't occur. for a to work it needs a and exp a. 
# pB <- c(0.1,0.9) #  
# peB <- c(0,1) # Note for toy version we can't have extreme values because sometimes all resample is false and then sd is zero
# # And wrap them into a df called params. 
# params <- data.frame(rbind(pA, peA, pB, peB))
# colnames(params) <- c(0,1)

# But causal strengths are the edges from exp1a, ie odds ratios. Some are between 0,1 so are inhibitory (make it half as likely to happen)
# Do noise nodes not have to be NOT on to make the effect work?

# Other values set outside for now 
N_cf <- 5000L # How many counterfactual samples to draw
s <- .7 # Stability

# ------------- Create world combos df ----------------- 
# A function to create the df of all the world combos, with probabilities

world_combos <- function(params, structure) { 
  n_causes <- nrow(params)
  causes <- rownames(params)
  # Make a df of all combinations of variable settings
  df <- expand.grid(rep(list(c(0,1)),n_causes), KEEP.OUT.ATTRS = F)
  # ... with variables as the column names
  colnames(df) <- causes
  worlds <- nrow(df)
  # Calculate EFFECT (E) depending on whether structure is disjunctive or conjunctive
  if (structure=="conjunctive") { 
    df$E <- as.numeric((df[1] & df[2]) & (df[3] & df[4])) # Let's handle causes!=4 later
  }
  if (structure=="disjunctive") { 
    df$E <- as.numeric((df[1] & df[2]) | (df[3] & df[4])) 
  }
  # Can replace with this - if rename - it is deterministic - literally gives specific outcome for set 3 causes, needs actual input. mechanical tell syou whether effects occurred given setting
  # df$effect <- max( c(min(c1,e1), min(c2,e2), min(c3, e3), min(c2*c3, e23))) # BUT SAME PROBLEM - HOW TO AUTOMATICALLY DEAL WITH ANY NUMBER OF CAUSES?
  mat <- as.matrix(df[,1:4])
  # Replace every cell with the relevant indexed edge strength from params
  for (k in 1:worlds){
    for (cause in causes) {
      a <- params[cause,df[k,cause]+1] # It needs the '+1' because r indexes from 1 not 0
      mat[k,cause] <- a 
    }
  }
  # For each row of df, the parameter is now the product of the same row of the intermediate mat
  df$Pr <- apply(mat, 1, prod) # This is how likely that setting of causes is. Sums to 1
  # If we DID have a noisy-OR it would look like this: # BUT should it not only work for conj pairs of C and U?
  # df$test <- as.numeric(unlist(1 - (1 - params[2,2] * df[1]) * (1 - params[4,2] * df[3])))
  df$index <- 1:nrow(df)
  df
}

# Function call to get the dfs

#dfd <- world_combos(params = params, structure = 'disjunctive')
#dfc <- world_combos(params = params, structure = 'conjunctive')


# ------------- CESM FUNCTION ----------------------------
# A function to run the generic minimal CESM. Takes arguments of:
# - params that lists the base rates and strengths of exog noise u vars
# - a df of all the world combos with probs, generated by function world_combos
# (some redundancy across these two functions but probably ok)

generic_cesm <- function(params, df) { 
  n_causes <- nrow(params)
  causes <- rownames(params)
  # Make same shape df to put the effect size / correlations in - it doesn't have to be empty because the values will be overwritten
  mp <- df[,1:4]
  worlds <- nrow(df)
  # From here on we assign responsibility to the causes by simulating cfs and counting in how many of them the outcome happened the same
  # First, loop through possible world settings 
  for (c_ix in 1:worlds)
  {
    # Take the current case
    case <- df[c_ix,]
    # Make an empty df to put the generated counterfactual settings in 
    cfs <- data.frame(matrix(NA, nrow = N_cf, ncol = ncol(df))) 
    colnames(cfs) <- colnames(df)
    cfs$Match <- rep(NA, N_cf)
    # Then, generate N counterfactuals
    for (i in 1:N_cf)
    {
      cf_cs <- as.numeric(case[1:n_causes]) # Set of causes from the current world
      # Now resample what needs to be resampled
      resample <- runif(n_causes) > s # Picks the ones to be resampled, the ones that are not within 'stability'
      p <- params[,2] # The second column, ie. the p_eachvar==1
      cf_cs[resample] <- runif(sum(resample)) < p[resample] # Resamples for T ones, and replaces the cf value
      # Pull out the possible worlds that match these outcomes
      idx = c(1:nrow(df)) # The index starts with everything
      for (j in 1:n_causes){
        idx = intersect(idx, which(df[,causes[j]]==cf_cs[j])) # Then progressively filters down for each cause that matches
      }
      # ...puts the corresponding cases in a variable
      cf_cases <- df[idx,] 
      # ... and counts them
      n_outcomes <- nrow(cf_cases)
      #Sample one outcome according to its probability - for us now this is deterministic so comment out and find a more general way
      cf_out_ix <- sample(x=1:n_outcomes, size = 1, p=cf_cases$pOutcome)
      cf <- cf_cases[cf_out_ix,] 
      # Check if it matches the true outcome; adds column T/F
      cf$Match <- cf$E==case$E
      # Add the current now-finished case of N to the collection of cfs
      cfs[i,] <- cf
    }
    # Now calculate cf responsibility for each cause 
    cor_sizes <- rep(NA, n_causes)
    for (cause in 1:n_causes)
    {
      # Calculate correlation - 
      # the second part sets correlation negative when cause is inhibitory
      cor_sizes[cause] <- cor(cfs[[causes[cause]]], cfs$Match) * (c(-1,1)[as.numeric(case[[causes[cause]]])+1]) 
    } 
    mp[c_ix,1:4] <- cor_sizes
    cat(c_ix, cor_sizes, '\n') 
  }
  mp$index <- 1:nrow(mp)
  mp
}


# Example function call, will print out 16 rows of 4 numbers 
#mp1d <- generic_cesm(params = params, df = dfd)
#mp1c <- generic_cesm(params = params, df = dfc)


# Now save outputs and params for use in `unobs.R` 
#save(params, dfd, dfc, mp1c, mp1d, file='forunobs.Rdata') # ie collider 1 is with pA and pB base rate .5,.5

