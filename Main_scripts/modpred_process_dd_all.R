############################################################################### 
###### Collider - tidy up model predictions FULL but for DIRECT DEPENDENCE  #####
###############################################################################


rm(list=ls())
library(rjson)
library(tidyverse)

# 64 obs for 16 4-var combinations x 2 (c,d) x 4 pgroups = 512 of 15
all <- read.csv('../model_data/alldd.csv') %>% replace(is.na(.), 0) 
# But as for beyond here we need everything now...!






all <- all %>% rename(A_cp = 2, Au_cp = 3, B_cp = 4, Bu_cp = 5)

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


# The column 'Cause' is TRUE if that variable became causal when it was flipped

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

# We can also add a column called isLat for just whether the node is latent (Au,Bu) or observed (A,B).
all <- all %>% mutate(isLat = if_else(grepl(c("^Au|^Bu"), node), 'TRUE', 'FALSE'))
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



# Also need a way to tag 'incoherent' or unreal values. 
# This includes ones where the actual cause was set to 0 manually, and also one brought in by 'complete'

# ---------- Get jsons of static worlds info used in experiment ------
# Get the jsons
# worlds <- fromJSON(file = '../Experiment/worlds.json')
# worldsdf <- as.data.frame(worlds) # 8 obs of 132 vars
# conds <- fromJSON(file = '../Experiment/conds.json')
# condsdf <- as.data.frame(conds) # 2 obs of 21 vars 




#Then we want to keep only pgroup1:3, as 4:6 is no longer needed (it is flipped A/B for 1:3 and so can collapse with counterbalancing)
#all <- all %>% filter(pgroup %in% c('1','2','3')) # 8160 obs of 25
# Can make a separate one for the pgroup==4 model test
#all4 <- all %>% filter(pgroup=='4')

# write this as csv in case need it later 
write.csv(all, '../model_data/tidied_predsdd.csv')



# Section to get modelNorm but for the direct dependency predictions
mpdd <- read.csv('../model_data/tidied_predsdd.csv') # 512 0f 19

mpdd$pgroup <- as.factor(mpdd$pgroup)
mpdd$node <- as.factor(mpdd$node)
mpdd$trialtype <- as.factor(mpdd$trialtype)
mpdd$structure <- as.factor(mpdd$structure)
mpdd$E <- as.factor(mpdd$E)


modelNormdd <- mpdd %>%  
  group_by(pgroup, trialtype, node, Cause) %>% 
  summarise(n = n()) %>% 
  filter(pgroup==1, Cause==TRUE) # Just take 1 pgroup because it's meaningless

# Now how to combine with ppt? Still need the actual values of the node
