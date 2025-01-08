####################################################### 
###### Collider - tidy up model predictions FULL  #####
#######################################################
# We saved the model predictions before, in a messy file, so as not to run the long prediction step again
# Now we can tidy it 

# This is the full set, with eg. vars incoherent under actual causation set to 0 (ie. the filename contains 'full')
# We also want to tidy the model predictions in a lesioned way, to eg. not treat for actual causation.
# For that, go to similar files `modpred_process_noactual`

rm(list=ls())
library(rjson)
library(tidyverse)
s_vals <- c(seq(0.00, 0.95, 0.05), seq(0.96, 0.99, 0.01)) 

all <- read.csv('../model_data/allnew.csv') %>% replace(is.na(.), 0) # 322560 of 24

all <- all %>% rename(A_cp = 13, Au_cp = 14, B_cp = 15, Bu_cp = 16,
                      vA = 2, vAu = 3, vB = 4, vBu = 5)

all$pgroup <- as.factor(all$pgroup)

#all <-  all %>% select(-c(X, structure.y, pgroup.y))

# Bring in trialtype and rename as the proper string name just in case
all$trialtype <- all$group
all$trialtype[all$trialtype==1 & all$structure=='disjunctive'] <- 'd1'
all$trialtype[all$trialtype==2 & all$structure=='disjunctive'] <- 'd2'
all$trialtype[all$trialtype==3 & all$structure=='disjunctive'] <- 'd3'
all$trialtype[all$trialtype==4 & all$structure=='disjunctive'] <- 'd4'
all$trialtype[all$trialtype==5 & all$structure=='disjunctive'] <- 'd5'
all$trialtype[all$trialtype==6 & all$structure=='disjunctive'] <- 'd6'
all$trialtype[all$trialtype==7 & all$structure=='disjunctive'] <- 'd7'

all$trialtype[all$trialtype==1 & all$structure=='conjunctive'] <- 'c1'
all$trialtype[all$trialtype==2 & all$structure=='conjunctive'] <- 'c2'
all$trialtype[all$trialtype==3 & all$structure=='conjunctive'] <- 'c3'
all$trialtype[all$trialtype==4 & all$structure=='conjunctive'] <- 'c4'
all$trialtype[all$trialtype==5 & all$structure=='conjunctive'] <- 'c5'

#--------- ACTUAL CAUSATION ------------ 
# For each variable, under *actual causation*, if its setting does not equal the effect, 
# then its setting can't have contributed to the outcome. So set it to 0. 
# Do this manually for each of the 4 vars as we can't find a quicker simpler way to do it.

# ----- could probably do this later too, then we don't need to rerun the big split. 
# Can treat for actual causation after the split but before calculating wa and normalisation in 'combine_per_s'
  
# all$A_cp[all$vA!=all$E] <- 0
# all$Au_cp[all$vAu!=all$E] <- 0
# all$B_cp[all$vB!=all$E] <- 0
# all$Bu_cp[all$vBu!=all$E] <- 0

# ---------- Conditional probability and weighted average -------------

# Multiply raw effect sizes by cond.prob for what will make up what we're calling 'weighted average', 
# and rename to follow same pattern as _cp, so we can pivot by what kind of model prediction it is
# (ITS POSSIBLE THIS IS NEVER USED BECAUSE WE SUMMARISE IT LATER ANYWAY in the 'modelNorm' steps.
# Rerun with all this commented?!
# ---------
# all[,26:29] <- all[,13:16]*all$cond 
# all <- all %>% rename(A_wa = 26, Au_wa = 27, B_wa = 28, Bu_wa = 29)
#                         
# # This is the step we were preparing for!
# # cp is the conditional cesm, and wa is that * con.probs
# # Now we want to structure it slightly longer, on node only, matching the 'cp' and the 'wa' to node
# all <- all %>% pivot_longer(cols = -c(X:group, V16:trialtype), names_to = c('node', '.value'),
#                               names_sep = '_') # Gives 768 of 15 vars (126 for each of 6 probgroups)

# Except we want to pivot without _wa, only _cp
all <- all %>% pivot_longer(cols = c(A_cp:Bu_cp), names_to = c('node', '.value'), names_sep = '_') 
# Gives 1290240 obs of 23 vars

# The unobserved variables have different explanatory role depending what we presume their value to be.
# So we need to split them out. First one with 6 (just for unobserved) 
all$node2 <- all$node
all$node[all$vAu=='0' & all$node2=="Au"] <- 'Au=0'
all$node[all$vAu=='1' & all$node2=="Au"] <- 'Au=1'
all$node[all$vBu=='0' & all$node2=="Bu"] <- 'Bu=0'
all$node[all$vBu=='1' & all$node2=="Bu"] <- 'Bu=1'
# Also need one with 8, where every node takes the value it has
all$node3 <- all$node
all$node3[all$vA=='0' & all$node2=='A'] <- 'A=0'
all$node3[all$vA=='1' & all$node2=='A'] <- 'A=1'
all$node3[all$vB=='0' & all$node2=='B'] <- 'B=0'
all$node3[all$vB=='1' & all$node2=='B'] <- 'B=1'

# Later we may delete this line and do the 0s elsewhere -- 16320 / 16128 - why is s in it?
all <- all %>% complete(pgroup, trialtype, node3, s, sens) # 1322496 of 25

#all$wa <- all$wa %>% replace(is.na(.), 0) 

# Get a tag of the unobserved variables' settings. Then we can group data by this for plotting
all <- all %>% unite("uAuB", vAu,vBu, sep= "", remove = FALSE)

# Also need a column for the actual settings
# They should be:
# c1: 000 
# c2: 010
# c3: 100
# c4: 110
# c5: 111
# d1: 000
# d2: 010
# d3: 011
# d4: 100
# d5: 101
# d6: 110
# d7: 111

all$grp <- all$group

all$grp[all$grp=='1'] <- 'A=0, B=0, | E=0'
all$grp[all$grp=='2'] <- 'A=0, B=1, | E=0'

all$grp[all$grp=='3' & all$structure=='disjunctive'] <- 'A=0, B=1, | E=1'
all$grp[all$grp=='3' & all$structure=='conjunctive'] <- 'A=1, B=0, | E=0'

all$grp[all$grp=='4' & all$structure=='disjunctive'] <- 'A=1, B=0, | E=0'
all$grp[all$grp=='4' & all$structure=='conjunctive'] <- 'A=1, B=1, | E=0'

all$grp[all$grp=='5' & all$structure=='disjunctive'] <- 'A=1, B=0, | E=1'
all$grp[all$grp=='5' & all$structure=='conjunctive'] <- 'A=1, B=1, | E=1'

all$grp[all$grp=='6'] <- 'A=1, B=1, | E=0'
all$grp[all$grp=='7'] <- 'A=1, B=1, | E=1'

# And same for the unobserved values only
all$uAuB2 <- all$uAuB
all$uAuB2[all$uAuB2=='00'] <- 'Au=0, Bu=0'
all$uAuB2[all$uAuB2=='01'] <- 'Au=0, Bu=1'
all$uAuB2[all$uAuB2=='10'] <- 'Au=1, Bu=0'
all$uAuB2[all$uAuB2=='11'] <- 'Au=1, Bu=1'

# We can also add a column called isLat for just whether the node is latent (Au,Bu) or observed (A,B).
all <- all %>% mutate(isLat = if_else(grepl(c("^Au|^Bu"), node3), 'TRUE', 'FALSE'))
# And one for whether the node is connected with A or B
all <- all %>% mutate(connectedWith = ifelse(node3=='A=0'|node3=='A=1'|node3=='Au=0'|node3=='Au=1', 'A', 'B'))

# But there is another more nuanced quality: realLatent...
# Sometimes the values of the unobserved variables can be inferred logically. These are NOT 'realLatent'.
# realLatent is when we genuinely don't know what values the unobserved variables take. (when poss >1 in the function `get_cond_probs`)
# It affects the following situations (easier to point out when it is NOT realLatent, and take the inverse)
# All unobserved are realLatent, except:
# c5: Au and Bu
# d2: Bu
# d3: Bu
# d4: Au
# d5: Au
# d6: Au and Bu

# Now encode those rules, putting FALSE. (Everything else is already correctly determined)
all$realLat <- all$isLat
all$realLat[all$trialtype=='c5'|all$trialtype=='d6'] <- FALSE
all$realLat[all$trialtype=='d2' & all$node2=='Bu'] <- FALSE
all$realLat[all$trialtype=='d3' & all$node2=='Bu'] <- FALSE
all$realLat[all$trialtype=='d4' & all$node2=='Au'] <- FALSE
all$realLat[all$trialtype=='d5' & all$node2=='Au'] <- FALSE

# write this as csv in case need it later 
write.csv(all, '../model_data/tidied_preds3.csv')

# Then split into the different s_vals and save as R.data
splitbys <- split(all, all$s)

for (st in 1:length(s_vals)) {
  mp <- splitbys[[st]]
  save(mp, file = paste0('../model_data/', s_vals[[st]], 'model.Rdata'))
}


