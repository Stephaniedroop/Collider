#################################################### 
###### Collider analysis - compare model preds #####
####################################################

# Script takes the processed data from the collider ppt expt 
# (which was cleaned and sliced in `mainbatch_preprocessing.R`) 
# and combining with model predictions, and visualising 

# THIS SCRIPT NOW SUPERSEDED BY `COMBINE_PPT_WITH_PREDS.R - DON'T USE THIS`

# library(tidyverse)
rm(list=ls())



# Read in processed ppt data
load('../Data/Data.Rdata', verbose = T)

# Read in model preds # see master script for indexing etc -- if change what is saved in masterscript, it'll affect here
load('../model_data/modpreds.rdata', verbose = T) # list of 3

modpredsc <- mod_preds[[1]][[2]] # 64 obs of 18
modpredsd <-mod_preds[[1]][[1]]

# Or maybe don't need, if plotting before could use multiple dfs at a time, just substitute in
wad <- as.data.frame(modpredsd %>% group_by(trialtype,node3) %>% summarise(predicted = sum(wa)))
wac <- as.data.frame(modpredsc %>% group_by(trialtype,node3) %>% summarise(predicted = sum(wa)))

# Gah need it the same name as the column
pg1prop <- pg1prop %>% rename(node3 = ansVar3)
pg2prop <- pg2prop %>% rename(node3 = ansVar3)
pg3prop <- pg3prop %>% rename(node3 = ansVar3)

# Split out the 'proportion' dfs into conjunctive and disjucntive
pg1c <- pg1prop %>% filter(grepl("^c", trialtype)) # 16 of 4
pg1d <- pg1prop %>% filter(grepl("^d", trialtype)) # 19 obs of 4
pg2c <- pg2prop %>% filter(grepl("^c", trialtype)) # 11 of 4
pg2d <- pg2prop %>% filter(grepl("^d", trialtype)) # 14 of 4
pg3c <- pg3prop %>% filter(grepl("^c", trialtype)) # 13 obs of 4
pg3d <- pg3prop %>% filter(grepl("^d", trialtype)) # 19 obs of 4

# Now we need the vectors of all the node values and trialtypes (c and d) 
# (so the columns can be there even when empty, for the chart we want)
nodevals <- as.data.frame(unique(modpredsc$node3))
names(nodevals) <- 'node3'
trialvalsc <- as.data.frame(unique(modpredsc$trialtype))
names(trialvalsc) <- 'trialtype'
trialvalsd <- as.data.frame(unique(modpredsd$trialtype))
names(trialvalsd) <- 'trialtype'

trialvalscvec <- as.vector(unique(modpredsc$trialtype))
fulltrialspecc <- c('A=0, B=0, | E=0','A=0, B=1, | E=0','A=1, B=0, | E=0','A=1, B=1, | E=0','A=1, B=1, | E=1')
trialvalsdvec <- as.vector(unique(modpredsd$trialtype))
fulltrialspecd <- c('A=0, B=0, | E=0','A=0, B=1, | E=0','A=0, B=1, | E=1', 'A=1, B=0, | E=0','A=1, B=1, | E=0','A=1, B=0, | E=1', 'A=1, B=1, | E=1')

# Some 'intermediate merges' 
# First, all trials and nodes for c and for d
emptyc <- merge(trialvalsc, nodevals)
emptyd <- merge(trialvalsd, nodevals)
# Then merge in the values of probability group 1 (need to do this for all probability groups)
emptypgc1 <- merge(emptyc, pg1c, all.x = T) %>% replace(is.na(.), 0)
emptypgc2 <- merge(emptyc, pg2c, all.x = T) %>% replace(is.na(.), 0)
emptypgc3 <- merge(emptyc, pg3c, all.x = T) %>% replace(is.na(.), 0)

emptypgd1 <- merge(emptyd, pg1d, all.x = T) %>% replace(is.na(.), 0)
emptypgd2 <- merge(emptyd, pg2d, all.x = T) %>% replace(is.na(.), 0)
emptypgd3 <- merge(emptyd, pg3d, all.x = T) %>% replace(is.na(.), 0)

# Then merge in the weighted average ('wa') model preds
fp1c <- merge(x = emptypgc1, y = wac, by = c('trialtype', 'node3'), all.x = T) %>% replace(is.na(.), 0) %>% group_by(trialtype) %>% mutate(pred = predicted / sum(predicted))
fp2c <- merge(x = emptypgc2, y = wac, by = c('trialtype', 'node3'), all.x = T) %>% replace(is.na(.), 0) %>% group_by(trialtype) %>% mutate(pred = predicted / sum(predicted))
fp3c <- merge(x = emptypgc3, y = wac, by = c('trialtype', 'node3'), all.x = T) %>% replace(is.na(.), 0) %>% group_by(trialtype) %>% mutate(pred = predicted / sum(predicted))

fp1d <- merge(x = emptypgd1, y = wad, by = c('trialtype', 'node3'), all.x = T) %>% replace(is.na(.), 0) %>% group_by(trialtype) %>% mutate(pred = predicted / sum(predicted))
fp2d <- merge(x = emptypgd2, y = wad, by = c('trialtype', 'node3'), all.x = T) %>% replace(is.na(.), 0) %>% group_by(trialtype) %>% mutate(pred = predicted / sum(predicted))
fp3d <- merge(x = emptypgd3, y = wad, by = c('trialtype', 'node3'), all.x = T) %>% replace(is.na(.), 0) %>% group_by(trialtype) %>% mutate(pred = predicted / sum(predicted))

# That gives us 6 dfs for plotting: probability groups 1:3, for c and for d

# Save
save(file = '../processed_data/fp.rdata', fp1c,fp2c,fp3c,fp1d,fp2d,fp3d, trialvalsdvec,trialvalscvec, fulltrialspecd,fulltrialspecc)
