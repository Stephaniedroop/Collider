#################################################### 
###### Collider analysis - compare model preds #####
####################################################


##### NOTE


# This is the old version of this script which has some very longwinded repeat calls on multiple datasets to merge
# The reason was I needed to make space for the categories that had 0. I did this in a very unskillful way
# Later I found a better way, without need to split the set into so many multiple dfs, 
# and I found how to use complete and factors with tally
# Only kept this for reference, but basically think can bin it?








# Script takes the processed data from the collider ppt expt 
# (which was cleaned and sliced in `mainbatch_preprocessing.R`) 
# and combines it with the preprocessed model predictions from `modpred_preprocessing.R`

# library(tidyverse)
rm(list=ls())

# Read in processed ppt data
load('../Data/Data.Rdata', verbose = T) # This is one big df, 'data', and the same thign split into summaries of how many people in each cell in each prob group
# and model data
mp <- read.csv('../model_data/tidied_preds.csv') # 480 obs of 25

# ------------ NEW SUMMARY / PROPORTION DFS --------------------
# Thinking we'll always work off the same big mp and ppt data dfs 


# Ongoing question: is it meaningful to combine the mps and data in a different way than what we have? 
# We always need some sort of summary of the ppt data

# There is a .Rmd of same name, which does a different task: it summarises the RealLatent and SelectA vars.
# If we want that here, we might need to rename this and bring those chunks back

# Summarise mp
modelNorm <- mp %>% # 288 of 5
  group_by(pgroup, trialtype, node3, .drop = FALSE) %>% 
  summarise(predicted = sum(wa)) %>% 
  mutate(normpred = predicted/sum(predicted)) # 288 seems ok

# Summarise participant data - first set factors so we can use tally
data$pgroup <- as.factor(data$pgroup)
data$node3 <- as.factor(data$node3)
data$trialtype <- as.factor(data$trialtype)

dataNorm <- data %>% # 
  group_by(pgroup, trialtype, node3, .drop=FALSE) %>% 
  tally %>% 
  mutate(prop=n/sum(n))

# Now merge - 576 of 5 -- CLOSEST THING TO SINGLE PREDICTION PER NODE/EXPLANATION 
combNorm <- merge(x=dataNorm, y=modelNorm) %>% 
  select(-predicted, -n) %>% 
  rename(cesm=normpred, ppts=prop) %>% 
  pivot_longer(cols = cesm:ppts, values_to = 'percent')



# ------------ PLotting ----------- 

settingstring <- 'Settings: p(A==1), p(Au==1), p(B==1), p(Bu==1) \n1) .1, .5, .8, .5 \n2) .5, .1, .5, .8 \n3) .1, .7, .8, .5'


# ----------- Main model prediction analysis - what now? -----------------------

# Still haven't got a real single number for each node 



# To get for pgroup1 (ie for the trials when they had the first prob parameters)
mp1d <- mp %>% filter(pgroup=='1', structure=='disjunctive') %>% group_by(trialtype, node3) %>% summarise(predicted = sum(wa))
mp1c <- mp %>% filter(pgroup=='1', structure=='conjunctive') %>% group_by(trialtype, node3) %>% summarise(predicted = sum(wa))
mp2d <- mp %>% filter(pgroup=='2', structure=='disjunctive') %>% group_by(trialtype, node3) %>% summarise(predicted = sum(wa))
mp2c <- mp %>% filter(pgroup=='2', structure=='conjunctive') %>% group_by(trialtype, node3) %>% summarise(predicted = sum(wa))
mp3d <- mp %>% filter(pgroup=='3', structure=='disjunctive') %>% group_by(trialtype, node3) %>% summarise(predicted = sum(wa))
mp3c <- mp %>% filter(pgroup=='3', structure=='conjunctive') %>% group_by(trialtype, node3) %>% summarise(predicted = sum(wa))
mp4d <- mp %>% filter(pgroup=='4', structure=='disjunctive') %>% group_by(trialtype, node3) %>% summarise(predicted = sum(wa))
mp4c <- mp %>% filter(pgroup=='4', structure=='conjunctive') %>% group_by(trialtype, node3) %>% summarise(predicted = sum(wa))
mp5d <- mp %>% filter(pgroup=='5', structure=='disjunctive') %>% group_by(trialtype, node3) %>% summarise(predicted = sum(wa))
mp5c <- mp %>% filter(pgroup=='5', structure=='conjunctive') %>% group_by(trialtype, node3) %>% summarise(predicted = sum(wa))
mp6d <- mp %>% filter(pgroup=='6', structure=='disjunctive') %>% group_by(trialtype, node3) %>% summarise(predicted = sum(wa))
mp6c <- mp %>% filter(pgroup=='6', structure=='conjunctive') %>% group_by(trialtype, node3) %>% summarise(predicted = sum(wa))

# Gah need it the same name as the column
pg1prop <- pg1prop %>% rename(node3 = ansVar3, pgroup = probgroup)
pg2prop <- pg2prop %>% rename(node3 = ansVar3, pgroup = probgroup)
pg3prop <- pg3prop %>% rename(node3 = ansVar3, pgroup = probgroup)
pg4prop <- pg4prop %>% rename(node3 = ansVar3, pgroup = probgroup)
pg5prop <- pg5prop %>% rename(node3 = ansVar3, pgroup = probgroup)
pg6prop <- pg6prop %>% rename(node3 = ansVar3, pgroup = probgroup)

# Split out the 'proportion' dfs into conjunctive and disjucntive
pg1c <- pg1prop %>% filter(grepl("^c", trialtype)) # 26 of 4
pg1d <- pg1prop %>% filter(grepl("^d", trialtype)) # 34 obs of 4
pg2c <- pg2prop %>% filter(grepl("^c", trialtype)) # 24 of 4
pg2d <- pg2prop %>% filter(grepl("^d", trialtype)) # 35 of 4
pg3c <- pg3prop %>% filter(grepl("^c", trialtype)) # 29 obs of 4
pg3d <- pg3prop %>% filter(grepl("^d", trialtype)) # 34 obs of 4
pg4c <- pg4prop %>% filter(grepl("^c", trialtype)) # 28 of 4
pg4d <- pg4prop %>% filter(grepl("^d", trialtype)) # 32 obs of 4
pg5c <- pg5prop %>% filter(grepl("^c", trialtype)) # 25 of 4
pg5d <- pg5prop %>% filter(grepl("^d", trialtype)) # 38 of 4
pg6c <- pg6prop %>% filter(grepl("^c", trialtype)) # 22 obs of 4
pg6d <- pg6prop %>% filter(grepl("^d", trialtype)) # 33 obs of 4

# Now we need the vectors of all the node values and trialtypes (c and d) 
# (so the columns can be there even when empty, for the chart we want)
# Do this by getting the unique values of nodes and of trialtypes for both conj and disj
nodevals <- as.data.frame(unique(mp$node3))
names(nodevals) <- 'node3'
trialvalsc <- as.data.frame(unique(pg1c$trialtype)) # Doesn't matter which one we take the names from; they all have them
names(trialvalsc) <- 'trialtype'
trialvalsd <- as.data.frame(unique(pg1d$trialtype))
names(trialvalsd) <- 'trialtype'

#dis <- mp %>% filter(structure=='disjunctive')
#con <- mp %>% filter(structure=='conjunctive')

trialvalscvec <- as.vector(unique(pg1c$trialtype))
# fulltrialspecc <- as.vector(unique(con$grp))
# fulltrialspecd <- as.vector(unique(dis$grp))
fulltrialspecc <- c('A=0, B=0, | E=0','A=0, B=1, | E=0','A=1, B=0, | E=0','A=1, B=1, | E=0','A=1, B=1, | E=1')
trialvalsdvec <- as.vector(unique(pg1d$trialtype))
fulltrialspecd <- c('A=0, B=0, | E=0','A=0, B=1, | E=0','A=0, B=1, | E=1', 'A=1, B=0, | E=0', 'A=1, B=0, | E=1', 'A=1, B=1, | E=0', 'A=1, B=1, | E=1')

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


# Some 'intermediate merges' 
# First, all trials and nodes for c and for d
emptyc <- merge(trialvalsc, nodevals)
emptyd <- merge(trialvalsd, nodevals)
# Then merge in the values of each probability group 
emptypgc1 <- merge(emptyc, pg1c, all.x = T) %>% replace(is.na(.), 0) 
emptypgc2 <- merge(emptyc, pg2c, all.x = T) %>% replace(is.na(.), 0)
emptypgc3 <- merge(emptyc, pg3c, all.x = T) %>% replace(is.na(.), 0)
emptypgc4 <- merge(emptyc, pg4c, all.x = T) %>% replace(is.na(.), 0)
emptypgc5 <- merge(emptyc, pg5c, all.x = T) %>% replace(is.na(.), 0)
emptypgc6 <- merge(emptyc, pg6c, all.x = T) %>% replace(is.na(.), 0)

emptypgd1 <- merge(emptyd, pg1d, all.x = T) %>% replace(is.na(.), 0)
emptypgd2 <- merge(emptyd, pg2d, all.x = T) %>% replace(is.na(.), 0)
emptypgd3 <- merge(emptyd, pg3d, all.x = T) %>% replace(is.na(.), 0)
emptypgd4 <- merge(emptyd, pg4d, all.x = T) %>% replace(is.na(.), 0)
emptypgd5 <- merge(emptyd, pg5d, all.x = T) %>% replace(is.na(.), 0)
emptypgd6 <- merge(emptyd, pg6d, all.x = T) %>% replace(is.na(.), 0)

# Replace empty cells because we need these for plotting
emptypgc1$structure[emptypgc1$structure=='0'] <- 
  emptypgc2$structure[emptypgc2$structure=='0'] <- 
  emptypgc3$structure[emptypgc3$structure=='0'] <- 
  emptypgc4$structure[emptypgc4$structure=='0'] <- 
  emptypgc5$structure[emptypgc5$structure=='0'] <- 
  emptypgc6$structure[emptypgc6$structure=='0'] <- 'conjunctive'

emptypgd1$structure[emptypgd1$structure=='0'] <- 
  emptypgd2$structure[emptypgd2$structure=='0'] <- 
  emptypgd3$structure[emptypgd3$structure=='0'] <- 
  emptypgd4$structure[emptypgd4$structure=='0'] <- 
  emptypgd5$structure[emptypgd5$structure=='0'] <- 
  emptypgd6$structure[emptypgd6$structure=='0'] <- 'disjunctive'

emptypgc1$pgroup[emptypgc1$pgroup=='0'] <- 
  emptypgd1$pgroup[emptypgd1$pgroup=='0'] <- '1'

emptypgc2$pgroup[emptypgc2$pgroup=='0'] <- 
  emptypgd2$pgroup[emptypgd2$pgroup=='0'] <- '2'

emptypgc3$pgroup[emptypgc3$pgroup=='0'] <- 
  emptypgd3$pgroup[emptypgd3$pgroup=='0'] <- '3'

emptypgc4$pgroup[emptypgc4$pgroup=='0'] <- 
  emptypgd4$pgroup[emptypgd4$pgroup=='0'] <- '4'

emptypgc5$pgroup[emptypgc5$pgroup=='0'] <- 
  emptypgd5$pgroup[emptypgd5$pgroup=='0'] <- '5'

emptypgc6$pgroup[emptypgc6$pgroup=='0'] <- 
  emptypgd6$pgroup[emptypgd6$pgroup=='0'] <- '6'

# Then merge in the weighted average ('wa') model preds
fp1c <- merge(x = emptypgc1, y = mp1c, by = c('trialtype', 'node3'), all.x = T) %>% replace(is.na(.), 0) %>% group_by(trialtype) %>% mutate(normpred = predicted / sum(predicted))
fp2c <- merge(x = emptypgc2, y = mp2c, by = c('trialtype', 'node3'), all.x = T) %>% replace(is.na(.), 0) %>% group_by(trialtype) %>% mutate(normpred = predicted / sum(predicted))
fp3c <- merge(x = emptypgc3, y = mp3c, by = c('trialtype', 'node3'), all.x = T) %>% replace(is.na(.), 0) %>% group_by(trialtype) %>% mutate(normpred = predicted / sum(predicted))
fp4c <- merge(x = emptypgc4, y = mp4c, by = c('trialtype', 'node3'), all.x = T) %>% replace(is.na(.), 0) %>% group_by(trialtype) %>% mutate(normpred = predicted / sum(predicted))
fp5c <- merge(x = emptypgc5, y = mp5c, by = c('trialtype', 'node3'), all.x = T) %>% replace(is.na(.), 0) %>% group_by(trialtype) %>% mutate(normpred = predicted / sum(predicted))
fp6c <- merge(x = emptypgc6, y = mp6c, by = c('trialtype', 'node3'), all.x = T) %>% replace(is.na(.), 0) %>% group_by(trialtype) %>% mutate(normpred = predicted / sum(predicted))

fp1d <- merge(x = emptypgd1, y = mp1d, by = c('trialtype', 'node3'), all.x = T) %>% replace(is.na(.), 0) %>% group_by(trialtype) %>% mutate(normpred = predicted / sum(predicted))
fp2d <- merge(x = emptypgd2, y = mp2d, by = c('trialtype', 'node3'), all.x = T) %>% replace(is.na(.), 0) %>% group_by(trialtype) %>% mutate(normpred = predicted / sum(predicted))
fp3d <- merge(x = emptypgd3, y = mp3d, by = c('trialtype', 'node3'), all.x = T) %>% replace(is.na(.), 0) %>% group_by(trialtype) %>% mutate(normpred = predicted / sum(predicted))
fp4d <- merge(x = emptypgd4, y = mp4d, by = c('trialtype', 'node3'), all.x = T) %>% replace(is.na(.), 0) %>% group_by(trialtype) %>% mutate(normpred = predicted / sum(predicted))
fp5d <- merge(x = emptypgd5, y = mp5d, by = c('trialtype', 'node3'), all.x = T) %>% replace(is.na(.), 0) %>% group_by(trialtype) %>% mutate(normpred = predicted / sum(predicted))
fp6d <- merge(x = emptypgd6, y = mp6d, by = c('trialtype', 'node3'), all.x = T) %>% replace(is.na(.), 0) %>% group_by(trialtype) %>% mutate(normpred = predicted / sum(predicted))

# Get some correlations for different conditions:
cor1c <- cor(x=fp1c$prop, y=fp1c$normpred) # .87
cor2c <- cor(x=fp2c$prop, y=fp2c$normpred) # .64
cor3c <- cor(x=fp3c$prop, y=fp3c$normpred) # .82
cor4c <- cor(x=fp4c$prop, y=fp4c$normpred) # .70
cor5c <- cor(x=fp5c$prop, y=fp5c$normpred) # .62
cor6c <- cor(x=fp6c$prop, y=fp6c$normpred) # .79
cor1d <- cor(x=fp1d$prop, y=fp1d$normpred) # .86
cor2d <- cor(x=fp2d$prop, y=fp2d$normpred) # .68
cor3d <- cor(x=fp3d$prop, y=fp3d$normpred) # .81
cor4d <- cor(x=fp4d$prop, y=fp4d$normpred) # .85
cor5d <- cor(x=fp5d$prop, y=fp5d$normpred) # .76
cor6d <- cor(x=fp6d$prop, y=fp6d$normpred) # .85


# Also look at global level, then at facet level. Then recreate the scatter plot

# In these, column 'predicted' is the weighted average cesm score for each of the 8 possible node values in the trialtype
# eg. for c1 in pgroup1, nodeA=0 is .186 which is the sum of the 4 possible settings of the unobserved vars
# In fp1c this is already summed to be the score for A=0 (column node3)
# Column Normpred is these values normalised for each trialtype
# I have checked against the model prediction csv, 'tidied_preds.csv'

# Save
save(file = '../processed_data/fp.rdata', 
     fp1c,fp2c,fp3c,fp4c,fp5c,fp6c,fp1d,fp2d,fp3d,fp4d,fp5d,fp6d, 
     trialvalsdvec,trialvalscvec, fulltrialspecd,fulltrialspecc,
     mp1c,mp2c,mp3c,mp4c,mp5c,mp6c,mp1d,mp2d,mp3d,mp4d,mp5d,mp6d)

# Now go to plots, in `plot_model_to_ppt.R`