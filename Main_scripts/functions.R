###########################################################################
################### GW - general CESM functions ###########################

# Functions to run counterfactual simulation and assign a quantity of responsibility to each of several causes.
# 1) function that calculates all possible observations of the causes ('worlds').
# Needs inputs of:
# -- cause variables, assuming these happen either 0,1 and their strengths, assuming in a vector of prob 0, prob 1
# -- causal structure, whether disjunctive or conjunctive

# 2) function that gets conditional probabilities 

# 3) function to get counterfactuals and effect size:
# -- simulates counterfactuals by resampling from the prior for vars with p=1-s where s=stability to real world.
# -- prints out correlation of effect with each causal variable across these simulated counterfactual worlds.

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
  df$structure <- structure
  #df <- cbind(df, mat) # BTW THIS IS A NEW LINE TO GET THE PROBS IN. Neil says not needed.
  df
}

# A function to get conditional probabilities from world settings and priors (needs as input the output of the function `world_combos` above)
# Originally from `unobs_a.r` 
# Important for determining 'realLatent', a quality needed later. Some notes below the function

get_cond_probs <- function(df) {
  # Set empty df of the size we need
  newdf <- data.frame(matrix(vector(), 0, ncol(df)+2), stringsAsFactors=F)
  # Set column names same as df but with an extra at the end for the conditional probability
  colnames(newdf) <- c(colnames(df), 'cond', 'group')
  # Get how many rows are in each setting of what we observed, ie. no of rows is how many settings of UNobserved vars is possible for each setting of ABE
  observed <- df %>% select(pA, pB, E) %>% group_by(pA, pB, E) %>% summarise(n = n())
  observed$group <- 1:nrow(observed)
  # This chunk attaches a normalised conditional probability and group number 
  # for each setting of possible UNobserved vars within each Observed group  
  for (x in 1:nrow(observed)) {
    case <- observed[x,]
    # Filter df for what settings of the unobserved vars are possible for each observed world
    poss <- df %>% filter(pA == case$pA, pB == case$pB, E == case$E)
    # And normalise the conditional probabilities
    poss$cond <- poss$Pr/sum(poss$Pr)
    # Give a number to the group
    poss$group <- x
    # And add that finished setting to the newdf
    newdf <- rbind(newdf, poss)
  }
  newdf
}




# Notes on realLatent
# Sometimes the values of the unobserved variables can be inferred logically. These are NOT 'realLatent'.
# realLatent is when we genuinely don't know what values the unobserved variables take. (when poss >1 in the function `get_cond_probs`)
# It affects the following situations (easier to point out when it is NOT realLatent, and take the inverse)
# All are realLatent, except:
# c5: Au and Bu
# d2: Bu
# d3: Bu
# d4: Au
# d5: Au
# d6L Au and Bu

n <- 10
pEq <- rep(0.5, 40000)

# ---------- Intermediate function for direct dependency ----------
# A function to run the generic minimal CESM. Takes arguments of:
# - params that lists the base rates and strengths of exog noise u vars
# - a df of all the world combos with probs, generated by function world_combos

# From quillien paper - not sure if this is the same
# Sampling propensity of var X = s(x) + 1-s Pr(x)
# eg if x=1 and has a prior of 0.1, and s=0.5, this is 0.5*1 + 0.5*0.1

get_dd <- function(params, structure, df) {
  n_causes <- nrow(params)
  causes <- rownames(params)
  structure <- structure
  p <- params[,2] # The p_eachvar==1 
  allcfs <- data.frame(nrow(0), ncol(9))
  mp <- df[,1:4]
  worlds <- nrow(df)
  
  for (c_ix in 1:worlds)
  {
    # Take the current case
    case <- df[c_ix,] # one obs of 8 - the real world
    
    for (cause in 1:n_causes)
    {
      # Change it for just the current cause
      cfs <- case
      cfs[[cause]] <- as.numeric(!cfs[[cause]]) # Might not need as numeric as we do it later too
      # Recalculate effect
      # Calculate effect (determinative)
      if (structure=="conjunctive") { 
        cfs$E <- as.numeric((cfs[1] & cfs[2]) & (cfs[3] & cfs[4])) 
      }
      if (structure=="disjunctive") { 
        cfs$E <- as.numeric((cfs[1] & cfs[2]) | (cfs[3] & cfs[4])) 
      }
      
      # Add column T/F for the ones that match
      cfs$Match <- cfs$E==case$E
      cfs$world <- c_ix
      # Then add cfs
      allcfs <- rbind(allcfs, cfs)
    } 
      #cor_sizes <- rep(NA, n_causes)
      #realcfs <- rep(NA, n_causes)
      
      # the second part sets correlation negative when cause pushes against effect taking state it took
      #cor_sizes[cause] <- cor(cfs[[causes[cause]]], cfs$Match) * (c(-1,1)[as.numeric(case[[causes[cause]]])+1])
      #realcfs[cause] <- sum(cfs[[causes[cause]]]!=case[[causes[cause]]])
      
      # (Note we can also do phi of counts, psych package)
    
      # We want to keep cfs somewhere, to know how many datapoints are used each time, and what the variance is
      # cfs$world <- c_ix
      # cfs$structure <- structure
      # cfs$s <- s
      # allcfs <- rbind(allcfs, cfs)
    #mp[c_ix,1:4] <- cor_sizes
    #mp[c_ix,5:8] <- realcfs
    #mp[c_ix, 5] <- sum(cfs$E==case$E)
    #mp$index <- 1:nrow(mp)
    #mp$structure <- structure
    #mp$s <- s
    #mp$sens <- sens
  }
  allcfs
}

test <- get_dd(params, 'disjunctive', df) # gives 64 = 16*4


# ------------- CESM FUNCTION ----------------------------
# A function to run the generic minimal CESM. Takes arguments of:
# - params that lists the base rates and strengths of exog noise u vars
# - a df of all the world combos with probs, generated by function world_combos
# (some redundancy across these two functions but probably ok)

# This used to be big function generic_cesm 
get_cfs <- function(params, structure, df, s, sens) { 
  s <- s
  sens <- sens
  #profvis({
  n_causes <- nrow(params)
  causes <- rownames(params)
  structure <- structure
  p <- params[,2] # The p_eachvar==1 
  
  #sentest <- runif(n_causes*N_cf) < sens
  pvec <- rep(p, times = N_cf) # Turn it into a 40k vec
  #pv <- rep(p, times = N_cf)
  # Now the real pvec to use has 0.5 for where in sentest is T, and the params for where sentest is F
  # pv[sentest] is the params from the positions where sentest==T
  #pEq[sentest] <- pv[sentest] # Now use pEq as the pvec
  
  mp <- df[,1:4]
  worlds <- nrow(df)
  
  # Loop through 16 possible world settings
  for (c_ix in 1:worlds)
  {
    # STABILITY: Generate vector of random numbers. The ones outside stability s are to be resampled. Put T for them
    resample <- runif(n_causes*N_cf) > s # 40k vec, with T for ones higher than the stability param 
    # Take the current case
    case <- df[c_ix,] # one obs of 8 - the real world
    # Repeat the cause settings of the current world 10000 times
    cf_csrep <- rep(as.numeric(case[1:n_causes]), times = N_cf) # 40k vec
    # Now resample from its prior each value whose place in resample was set to TRUE in stability step
    cf_csrep[resample] <- runif(sum(resample)) < pvec[resample] # replace with pEq if use my way
    # Express these generated counterfactuals in tabular form again
    cfs <- data.frame(matrix(cf_csrep, nrow = N_cf, byrow = T))
    colnames(cfs) <- causes
    
    # Neil's 
    p_vec_prime <- (1-sens)*rep(.5, length(pvec)) + sens * pvec
    cf_csrep[resample] <- runif(sum(resample)) < p_vec_prime[resample] 
    
    # Calculate effect (determinative)
    if (structure=="conjunctive") { 
      cfs$E <- as.numeric((cfs[1] & cfs[2]) & (cfs[3] & cfs[4])) 
    }
    if (structure=="disjunctive") { 
      cfs$E <- as.numeric((cfs[1] & cfs[2]) | (cfs[3] & cfs[4])) 
    }
   
    # Add column T/F for the ones that match
    cfs$Match <- cfs$E==case$E
    
    cor_sizes <- rep(NA, n_causes)
    realcfs <- rep(NA, n_causes)
    for (cause in 1:n_causes)
    {
      # the second part sets correlation negative when cause pushes against effect taking state it took
      cor_sizes[cause] <- cor(cfs[[causes[cause]]], cfs$Match) * (c(-1,1)[as.numeric(case[[causes[cause]]])+1])
      realcfs[cause] <- sum(cfs[[causes[cause]]]!=case[[causes[cause]]])
    }
    # (Note we can also do phi of counts, psych package)
    
    # We want to keep cfs somewhere, to know how many datapoints are used each time, and what the variance is
    # cfs$world <- c_ix
    # cfs$structure <- structure
    # cfs$s <- s
    # allcfs <- rbind(allcfs, cfs)
    mp[c_ix,1:4] <- cor_sizes
    mp[c_ix,5:8] <- realcfs
    mp[c_ix, 9] <- sum(cfs$E==case$E)
    mp$index <- 1:nrow(mp)
    mp$structure <- structure
    mp$s <- s
  }
  mp
}
  