##################################################################
################### GW - general CESM ############################

# A script to test intuitions of unobserved u vars in a collider, both disjunctive and conjunctive

# This is script 2/3, in a series where 1) is `general_cesm.r`, 3) is `collider_plot.r`

# NOW AFTER TADEG'S HALPERN ACTUAL CAUSATION POINT, THIS IS VERSION..._a WHERE WE WEED OUT OBVIOUS NON-CAUSES

# ------- Prelims -----------

#rm(list=ls())
#library(tidyverse)


# Load params of 4 cause vars, the world combos in disjunctive and conjunctive collider settings, 
# and model predictions for each from the `general_cesm` function in `general_cesm.R`
#load('collider2.rdata', verbose = T) 

# Key point: If peA and peB are unobserved, what can we say about them for each row?

# load('../model_data/1intmodpreds.Rdata', verbose = T) # and 2 and 3
# 
# 
# 
# # ---------- Get conditional probabilities for each observed world ---------------
# # DISJUNCTIVE
# 
# # Set empty df of the size we need
# newdfd <- data.frame(matrix(vector(), 0, 9), stringsAsFactors=F)
# # Set column names same as df but with an extra at the end for the conditional probability
# colnames(newdfd) <- c(colnames(dfd), 'cond', 'group')
# 
# # Get how many rows are in each setting of what we observed, ie. no of rows is how many settings of UNobserved vars is possible in each group
# observedd <- dfd %>% select(pA, pB, E) %>% group_by(pA, pB, E) %>% summarise(n = n())
# observedd$group <- 1:nrow(observedd)
# 
# # This chunk attaches a normalised conditional probability and group number 
# # for each setting of possible UNobserved vars within each Observed group  
# for (x in 1:nrow(observedd)) {
#   case <- observedd[x,]
#   # Filter df for what settings of the unobserved vars are possible for each observed world
#   poss <- dfd %>% filter(pA == case$pA, pB == case$pB, E == case$E)
#   # And normalise the conditional probabilities
#   poss$cond <- poss$Pr/sum(poss$Pr)
#   # Give a number to the group
#   poss$group <- x
#   # And add that finished setting to the newdf
#   newdfd <- rbind(newdfd, poss)
# }
#   
# # CONJUNCTIVE
# 
# newdfc <- data.frame(matrix(vector(), 0, 9), stringsAsFactors=F)
# # Set column names same as df but with an extra at the end for the conditional probability
# colnames(newdfc) <- c(colnames(dfc), 'cond', 'group')
# 
# observedc <- dfc %>% select(pA, pB, E) %>% group_by(pA, pB, E) %>% summarise(n = n())
# observedc$group <- 1:nrow(observedc)
# 
# for (x in 1:nrow(observedc)) {
#   case <- observedc[x,]
#   # Filter df for what settings of the unobserved vars are possible for each observed world
#   poss <- dfc %>% filter(pA == case$pA, pB == case$pB, E == case$E)
#   poss$cond <- poss$Pr/sum(poss$Pr)
#   poss$group <- x
#   newdfc <- rbind(newdfc, poss)
# }



#Actually did this in a function in the same file as general_cesm_a. Then when we merge the model preds and df

# ALL DOWN TO HERE IS NOW OBSOLETE

# ------- Get model preds ready for plotting and remove non-actual causes ------------------

# Want a bar of weighted average cesm, but ggplot itself will sum the parts. If we ever need weighted average elsewhere, will need to calculate   

# DISJUNCTIVE

# Merge model predictions with df of normalised conditional probabilities
alld <- merge(x = mp1d, y = newdfd, by = c('index')) # 16 obs of 13 vars

# Many cols need simpler names
alld <- alld %>% rename(A = 2, Au = 3, B = 4, Bu = 5, vA = 6, vAe = 7, vB = 8, vBe = 9)

# For each variable, under *actual causation*, if its setting does not equal the effect, 
# then its setting can't have contributed to the outcome. So set it to 0. 
# Do this manually for each of the 4 vars as we can't find a quicker simpler way to do it.

alld$A[alld$vA!=alld$E] <- 0
alld$Au[alld$vAe!=alld$E] <- 0
alld$B[alld$vB!=alld$E] <- 0
alld$Bu[alld$vBe!=alld$E] <- 0

# Multiply effect sizes by cond.prob for what will make up what we're calling 'weighted average'
alld[,14:17] <- alld[,2:5]*alld$cond 

# To pivot_longer two sets of columns, rename them in two groups
alld <- alld %>% rename(A_cp = 2, Au_cp = 3, B_cp = 4, Bu_cp = 5, 
                        A_wa = 14, Au_wa = 15, B_wa = 16, Bu_wa = 17)

# At least now we have the values we need on the same df - cp is the conditional cesm, and wa is that * con.probs
alld <- alld %>% pivot_longer(cols = -c(index, vA:group), names_to = c('node', '.value'),
                              names_sep = '_')

# Get a tag of the unobserved variables' settings. Then we can group data by this for plotting
alld <- alld %>% unite("uAuB", vAe,vBe, sep= "", remove = FALSE)

# The unobserved variables have different explanatory role depending what we presume their value to be.
# So we need to split them out.
alld$node2 <- alld$node
alld$node[alld$vAe=='0' & alld$node2=="Au"] <- 'Au=0'
alld$node[alld$vAe=='1' & alld$node2=="Au"] <- 'Au=1'
alld$node[alld$vBe=='0' & alld$node2=="Bu"] <- 'Bu=0'
alld$node[alld$vBe=='1' & alld$node2=="Bu"] <- 'Bu=1'
# Thus 'node' has become the one with 6
# Also need one with 8
alld$node3 <- alld$node
alld$node3[alld$vA=='0' & alld$node2=='A'] <- 'A=0'
alld$node3[alld$vA=='1' & alld$node2=='A'] <- 'A=1'
alld$node3[alld$vB=='0' & alld$node2=='B'] <- 'B=0'
alld$node3[alld$vB=='1' & alld$node2=='B'] <- 'B=1'



# Bring in trialtype and rename as the proper string name just in case
alld$trialtype <- alld$group
alld$trialtype[alld$trialtype==1] <- 'd1'
alld$trialtype[alld$trialtype==2] <- 'd2'
alld$trialtype[alld$trialtype==3] <- 'd3'
alld$trialtype[alld$trialtype==4] <- 'd4'
alld$trialtype[alld$trialtype==5] <- 'd5'
alld$trialtype[alld$trialtype==6] <- 'd6'
alld$trialtype[alld$trialtype==7] <- 'd7'



# CONJUNCTIVE


# Merge model predictions with df of normalised conditional probabilities
allc <- merge(x = mp1c, y = newdfc, by = c('index')) # 16 obs of 13 vars

# Many cols need simpler names
allc <- allc %>% rename(A = 2, Au = 3, B = 4, Bu = 5, vA = 6, vAe = 7, vB = 8, vBe = 9)

# For each variable, under *actual causation*, if its setting does not equal the effect, 
# then its setting can't have contributed to the outcome. So set it to 0. 
# Do this manually for each of the 4 vars as we can't find a quicker simpler way to do it.

allc$A[allc$vA!=allc$E] <- 0
allc$Au[allc$vAe!=allc$E] <- 0
allc$B[allc$vB!=allc$E] <- 0
allc$Bu[allc$vBe!=allc$E] <- 0

# Multiply effect sizes by cond.prob for what will make up what we're calling 'weighted average'
allc[,14:17] <- allc[,2:5]*allc$cond 

# To pivot_longer two sets of columns, rename them in two groups
allc <- allc %>% rename(A_cp = 2, Au_cp = 3, B_cp = 4, Bu_cp = 5, 
                        A_wa = 14, Au_wa = 15, B_wa = 16, Bu_wa = 17)

# At least now we have the values we need on the same df - cp is the conditional cesm, and wa is that * con.probs
allc <- allc %>% pivot_longer(cols = -c(index, vA:group), names_to = c('node', '.value'),
                              names_sep = '_')

# Get a tag of the unobserved variables' settings. Then we can group data by this for plotting
allc <- allc %>% unite("uAuB", vAe,vBe, sep= "", remove = FALSE)

# The unobserved variables have different explanatory role depending what we presume their value to be.
# So we need to split them out.
allc$node2 <- allc$node
allc$node[allc$vAe=='0' & allc$node2=="Au"] <- 'Au=0'
allc$node[allc$vAe=='1' & allc$node2=="Au"] <- 'Au=1'
allc$node[allc$vBe=='0' & allc$node2=="Bu"] <- 'Bu=0'
allc$node[allc$vBe=='1' & allc$node2=="Bu"] <- 'Bu=1'
# Thus 'node' has become the one with 6
# Also need one with 8
allc$node3 <- allc$node
allc$node3[allc$vA=='0' & allc$node2=='A'] <- 'A=0'
allc$node3[allc$vA=='1' & allc$node2=='A'] <- 'A=1'
allc$node3[allc$vB=='0' & allc$node2=='B'] <- 'B=0'
allc$node3[allc$vB=='1' & allc$node2=='B'] <- 'B=1'


# Bring in trialtype and rename as the proper string name just in case
allc$trialtype <- allc$group
allc$trialtype[allc$trialtype==1] <- 'c1'
allc$trialtype[allc$trialtype==2] <- 'c2'
allc$trialtype[allc$trialtype==3] <- 'c3'
allc$trialtype[allc$trialtype==4] <- 'c4'
allc$trialtype[allc$trialtype==5] <- 'c5'



# ---------- Now actually take the data for plotting --------------
forplotd <- alld
forplotc <- allc

# ------------ RENAME SOME CELLS FOR PRETTIER CHARTS -----------------
# DISJ
# Copy column in case mess it up
forplotd$grp <- forplotd$group
# Replace values according to conditions
forplotd$grp[forplotd$grp=="1"] <- 'A=0, B=0, | E=0'
forplotd$grp[forplotd$grp=="2"] <- 'A=0, B=1, | E=0'
forplotd$grp[forplotd$grp=="3"] <- 'A=0, B=1, | E=1'
forplotd$grp[forplotd$grp=="4"] <- 'A=1, B=0, | E=0'
forplotd$grp[forplotd$grp=="5"] <- 'A=1, B=0, | E=1'
forplotd$grp[forplotd$grp=="6"] <- 'A=1, B=1, | E=0'
forplotd$grp[forplotd$grp=="7"] <- 'A=1, B=1, | E=1'
# And copy this column
forplotd$uAuB2 <- forplotd$uAuB
# And replace these values
forplotd$uAuB2[forplotd$uAuB2=='00'] <- 'Au=0, Bu=0'
forplotd$uAuB2[forplotd$uAuB2=='01'] <- 'Au=0, Bu=1'
forplotd$uAuB2[forplotd$uAuB2=='10'] <- 'Au=1, Bu=0'
forplotd$uAuB2[forplotd$uAuB2=='11'] <- 'Au=1, Bu=1'

# CONJ
# Copy column in case mess it up
forplotc$grp <- forplotc$group
# Replace values according to conditions
forplotc$grp[forplotc$grp=="1"] <- 'A=0, B=0, | E=0'
forplotc$grp[forplotc$grp=="2"] <- 'A=0, B=1, | E=0'
forplotc$grp[forplotc$grp=="3"] <- 'A=1, B=0, | E=0'
forplotc$grp[forplotc$grp=="4"] <- 'A=1, B=1, | E=0'
forplotc$grp[forplotc$grp=="5"] <- 'A=1, B=1, | E=1'

# And copy this column
forplotc$uAuB2 <- forplotc$uAuB
# And replace these values
forplotc$uAuB2[forplotc$uAuB2=='00'] <- 'Au=0, Bu=0'
forplotc$uAuB2[forplotc$uAuB2=='01'] <- 'Au=0, Bu=1'
forplotc$uAuB2[forplotc$uAuB2=='10'] <- 'Au=1, Bu=0'
forplotc$uAuB2[forplotc$uAuB2=='11'] <- 'Au=1, Bu=1'



