# Cut material in case we need it for the collider case








# Plot was summing across all wa vals, even when they are the same. So what about trying to plot directly from alld - what would have to happen?

# alld <- alld %>% pivot_longer(
#   cols = A.1:Bu.1,
#   names_to = 'node',
#   values_to = 'wa'
# )
# 
# alld <- alld %>% pivot_longer(
#   cols = A:Bu,
#   names_to = 'node2',
#   values_to = 'pred'
# )









# LATEST - FRI AFTERNOON UNFINISHED BUT HAD TO LEAVE ----- 
# Now the wa col for A can be summed in the plot and that will give the true wa for A
# But neil has problem with the points - they are currently summed to give the wa, but he wanted them unsummed(?)
# Go back to alld and see if can bring in the old 'pred' before multiplied with prob. (cols 2:5)
# But then we face the old problem
# And of course none of this was done to conj case yet, or to anything other than the case 9 for testing.

# Expected[CESM_score] = 
# conditional_CESM_score*probability_of_that_state + 
# conditional_CESM_score*probability_of_that_state 
# for all possible states of the unobserved stuff 
# Plot conditional cesm scores as points directly


# --------  Get weighted average by group -------------
# Here we need to rename the intermediate wa cols the same as the original cesm sizes, 
# because later to get them all on the same plot we need both a prediction and a wa value for each var(A,B etc).
# wa_cesm_d <- alld %>% select(!(2:5)) %>% group_by(group) %>% 
#   summarise(A = sum(mpA), 
#             Au0 = sum(mpAe[vAe=='0']), 
#             Au1 = sum(mpAe[vAe=='1']), 
#             B = sum(mpB), 
#             Bu0 = sum(mpBe[vBe=='0']), 
#             Bu1 = sum(mpBe[vBe=='1']))

# Some are NaN because 0/0, can just replace with 0
# wa_cesm_d[is.na(wa_cesm_d)] <- 0

# And get in long format for later charting
# wa_cesm_d <- wa_cesm_d %>% pivot_longer(
#   cols = A:Bu1,
#   names_to = "node",
#   values_to = "wa"
# )

# Now do same for conj case... with fewer notes this time. Go back to the disjunctive notes for rationale
# CONJUNCTIVE
allc <- merge(x = mp1c, y = newdfc, by = c('index')) # 16 obs of 13 vars

allc <- allc %>% rename(A = 2, Au = 3, B = 4, Bu = 5, vA = 6, vAe = 7, vB = 8, vBe = 9)

# For each variable, if its setting does not equal the effect, then its setting can't have contributed to the outcome. 
# So set it to 0. Do this separately for each of the 4 vars as we can't find a quicker simpler way to do it.
allc$A[allc$vA!=allc$E] <- 0
allc$Au[allc$vAe!=allc$E] <- 0
allc$B[allc$vB!=allc$E] <- 0
allc$Bu[allc$vBe!=allc$E] <- 0

# Multiply effect sizes by cond.prob
allc[,14:17] <- allc[,2:5]*allc$cond # 16 obs of 17 vars

allc <- allc %>% rename(mpA = 14, mpAe = 15, mpB = 16, mpBe = 17)

# Sum by group
wa_cesm_c <- allc %>% select(!(2:5)) %>% group_by(group) %>% 
  summarise(A = sum(mpA), 
            Au0 = sum(mpAe[vAe=='0']), 
            Au1 = sum(mpAe[vAe=='1']), 
            B = sum(mpB), 
            Bu0 = sum(mpBe[vBe=='0']), 
            Bu1 = sum(mpBe[vBe=='1']))

wa_cesm_c <- wa_cesm_c %>% pivot_longer(
  cols = A:Bu1,
  names_to = "node",
  values_to = "wa"
)

# ----------- Merging etc ---------------
# Now put together effect sizes and the world variable settings, for all the observable settings
# worlds_effectsizes_d <- merge(x = wa_cesm_d, y = observedd, by = c('group'))
# worlds_effectsizes_c <- merge(x = wa_cesm_c, y = observedc, by = c('group'))
# 
# # For disj -----
# # Now I make a separate df for plotting the individual predictions, from col2:5 from alld that were excluded last time
# summd <- alld %>% select(1:5,7,9,13) %>% pivot_longer(
#   cols = A:Bu,
#   names_to = "node",
#   values_to = "pred"
# )
# 
# # These now need to be renamed the same as in the other df to separate the two possible values of each u node, to plot together
# # So first take a copy of the node column
# summd$node2 <- summd$node
# # And then replace the conglomerate Au and Bu names with their split-out values, as per the node's settings
# summd$node[summd$vAe=='0' & summd$node2=="Au"] <- 'Au0'
# summd$node[summd$vAe=='1' & summd$node2=="Au"] <- 'Au1'
# summd$node[summd$vBe=='0' & summd$node2=="Bu"] <- 'Bu0'
# summd$node[summd$vBe=='1' & summd$node2=="Bu"] <- 'Bu1'
# # And this will then get merged with the wa df to take or plotting
# forplotd <- merge(x = summd, y = worlds_effectsizes_d, by = c('group', 'node')) %>% 
#   unite("uAuB", vAe:vBe, sep= "", remove = TRUE)
# 
# # Now do the same for the conj setting
# summc <- allc %>% select(1:5,7,9,13) %>% pivot_longer(
#   cols = A:Bu,
#   names_to = "node",
#   values_to = "pred"
# )
# 
# summc$node2 <- summc$node
# # And then replace the conglomerate Au and Bu names with their split-out values, as per the node's settings
# summc$node[summc$vAe=='0' & summc$node2=="Au"] <- 'Au0'
# summc$node[summc$vAe=='1' & summc$node2=="Au"] <- 'Au1'
# summc$node[summc$vBe=='0' & summc$node2=="Bu"] <- 'Bu0'
# summc$node[summc$vBe=='1' & summc$node2=="Bu"] <- 'Bu1'
# 
# forplotc <- merge(x = summc, y = worlds_effectsizes_c, by = c('group', 'node')) %>% 
#   unite("uAuB", vAe:vBe, sep= "", remove = TRUE)

