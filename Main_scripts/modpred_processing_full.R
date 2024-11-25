#################################################### 
###### Collider - tidy up model predictions  #####
####################################################
# We saved the model predictions before, in a messy file, so as not to run the long prediction step again
# Now we can tidy it 

# This is the full set, with eg. vars incoherent under actual causation set to 0 (ie. the filename contains 'full')
# We also want to tidy the model predictions in a lesioned way, to eg. not treat for actual causation.
# For that, go to similar files `modpred_process_noactual`

rm(list=ls())
library(rjson)
library(tidyverse)


# 2016 of 12
model_preds <- all %>% select(-c(V5:V9, structure.y, pgroup.y)) %>% 
  rename(structure = structure.x,
         pgroup = pgroup.x,
         A = pA.x,
         Au = peA.x,
         B = pB.x,
         Bu = peB.x) %>% 
  group_by(s, pgroup, structure, index) %>% summarise(meanA = mean(A),
                                                      sdA = sd(A),
                                                      meanAu = mean(Au),
                                                      sdAu = sd(Au),
                                                      meanB = mean(Bu),
                                                      sdB = sd(B),
                                                      meanBu = mean(Bu),
                                                      sdBu = sd(Bu), na.rm=T)

model_preds2 <- as.data.frame(model_preds)

ss <- model_preds2 %>% filter(s==0.00, pgroup==1)


sss <- all %>% filter(s==0, pgroup.x==1, structure.x=='disjunctive', index==1)

maxvars <- model_preds2 %>% summarise(maxsdA = max(sdA, na.rm = TRUE),
                                      maxsdAu = max(sdAu, na.rm = TRUE),
                                      maxsdB = max(sdB, na.rm = TRUE),
                                      maxsdBu = max(sdBu, na.rm = TRUE))

meanvars <- model_preds2 %>% summarise(maxsdA = mean(sdA, na.rm = TRUE),
                                       maxsdAu = mean(sdAu, na.rm = TRUE),
                                       maxsdB = mean(sdB, na.rm = TRUE),
                                       maxsdBu = mean(sdBu, na.rm = TRUE))

minvars <- model_preds2 %>% summarise(maxsdA = min(sdA, na.rm = TRUE),
                                      maxsdAu = min(sdAu, na.rm = TRUE),
                                      maxsdB = min(sdB, na.rm = TRUE),
                                      maxsdBu = min(sdBu, na.rm = TRUE))

sdvars <- model_preds2 %>% summarise(maxsdA = sd(sdA, na.rm = TRUE),
                                     maxsdAu = sd(sdAu, na.rm = TRUE),
                                     maxsdB = sd(sdB, na.rm = TRUE),
                                     maxsdBu = sd(sdBu, na.rm = TRUE))


#all <- read.csv('../model_data/all.csv') %>% replace(is.na(.), 0) # 4032 of 19. now 20160 of 25

all <- all %>% rename(A_cp = 3, Au_cp = 4, B_cp = 5, Bu_cp = 6, 
                      structure = 12, pgroup = 15,
                      vA = 16, vAu = 17, vB = 18, vBu = 19)

all$pgroup <- as.factor(all$pgroup)

all <-  all %>% select(-c(X, structure.y, pgroup.y))

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
  
all$A_cp[all$vA!=all$E] <- 0
all$Au_cp[all$vAu!=all$E] <- 0
all$B_cp[all$vB!=all$E] <- 0
all$Bu_cp[all$vBu!=all$E] <- 0

# ---------- Conditional probability and weighted average -------------

# Multiply raw effect sizes by cond.prob for what will make up what we're calling 'weighted average', 
# and rename to follow same pattern as _cp, so we can pivot by what kind of model prediction it is
all[,24:27] <- all[,2:5]*all$cond 
all <- all %>% rename(A_wa = 24, Au_wa = 25, B_wa = 26, Bu_wa = 27)
                        
# This is the step we were preparing for!
# cp is the conditional cesm, and wa is that * con.probs
# Now we want to structure it slightly longer, on node only, matching the 'cp' and the 'wa' to node
all <- all %>% pivot_longer(cols = -c(index, V5:trialtype), names_to = c('node', '.value'),
                              names_sep = '_') # Gives 768 of 15 vars (126 for each of 6 probgroups)



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

# Later we may delete this line and do the 0s elsewhere -- 16320 / 16128
all <- all %>% complete(pgroup, trialtype, node3, s) # 20160 - problem because lots of NAs 82656 of 24

# Structure
all$structure <- if_else(grepl("^c", all$trialtype), 'conjunctive', 'disjunctive')
all$wa <- all$wa %>% replace(is.na(.), 0) 

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
# (This same thing can go to the ppt data)

# And then we need a way to summarise the proportions. This is like done in normalisation?


# Also need a way to tag 'incoherent' or unreal values. 
# This includes ones where the actual cause was set to 0 manually, and also one brought in by 'complete'

# ---------- Get jsons of static worlds info used in experiment ------
# Get the jsons
# worlds <- fromJSON(file = '../Experiment/worlds.json')
# worldsdf <- as.data.frame(worlds) # 8 obs of 132 vars
# conds <- fromJSON(file = '../Experiment/conds.json')
# condsdf <- as.data.frame(conds) # 2 obs of 21 vars 




# Then we want to keep only pgroup1:3, as 4:6 is no longer needed (it is flipped A/B for 1:3 and so can collapse with counterbalancing)
#all <- all %>% filter(pgroup %in% c('1','2','3')) # 8160 obs of 25


# write this as csv in case need it later 
write.csv(all, '../model_data/tidied_preds2.csv')

# Get a single CESM number for each node, disregarding possible settings
# weight <- all %>% group_by(pgroup, trialtype, node2) %>% summarise(weight = sum(wa))

# Now go to `combine_ppt_with_preds.R` to combine these tidied predictions with the processed ppt data from `mainbatch_preprocessing.R`






