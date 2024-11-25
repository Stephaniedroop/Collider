##################################################################
########### GW - plotting model predictions for collider #########

# A script to plot model predictions for collider, both disjunctive and conjunctive
# Two observed variables, A and B, and two unobserved, which are the noise variables of A and B

# This is script 3/3, in a series where 1) is `general_cesm.r`, 2) is `unobs.r`

# NOW AFTER TADEG'S HALPERN ACTUAL CAUSATION POINT, THIS IS VERSION..._a WHERE WE WEED OUT OBVIOUS NON-CAUSES
# It is also different from the previous script in that the bars are split out for the different values of the u nodes

# ------- Prelims -----------

#rm(list=ls())
# library(tidyverse)


# Load params of 4 cause vars, the world combos in disjunctive and conjunctive collider settings, 
# and model predictions for each from the `general_cesm` function in `general_cesm.R`
#load('unobsforplot12.Rdata', verbose = T) # 2 x 64 obs of 10 vars, plus params

# ------------- PLOTS ----------------------

# [which(forplotd$pred!=0),] -- put this back in the top line if we do decide it's needed. Looks like it was summing across all wa, so ned to rethink

# DISJ 



pd <- ggplot(forplotd, aes(x = node, y = cp,
                      fill = node)) +
  geom_col(aes(x = node, y = wa), alpha = 0.4) +
  facet_wrap(~grp) + #, scales='free_x'
  geom_point(aes(colour=uAuB2, shape=uAuB2), size=3) +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90)) +
  guides(fill = guide_legend(override.aes = list(size = 0, alpha=0.4))) +
  labs(x='Node', y='Effect size', fill='Weighted average \neffect size', 
       shape='Assuming unobserved \nvariables are...', 
       colour='Assuming unobserved \nvariables are...',
       title = 'Disjunctive collider',
       subtitle = paste0('pA=',poss_params[[i]][1,2],', pAu=',poss_params[[i]][2,2], 
                         ', pB=',poss_params[[i]][3,2], ', pBu=',poss_params[[i]][4,2]))

pd
#ggsave('~/Documents/GitHub/gw/dcollider.pdf', width = 7, height = 5, units = 'in')

# CONJ

pc <- ggplot(forplotc, aes(x = node, y = cp,
                           fill = node)) +
  geom_col(aes(x = node, y = wa), alpha = 0.4) +
  facet_wrap(~grp) + #, scales='free_x'
  geom_point(aes(colour=uAuB2, shape=uAuB2), size=3) +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90)) +
  guides(fill = guide_legend(override.aes = list(size = 0, alpha=0.4))) +
  labs(x='Node', y='Effect size', fill='Weighted average \neffect size', 
       shape='Assuming unobserved \nvariables are...', 
       colour='Assuming unobserved \nvariables are...',
       title = 'Conjunctive collider',
       subtitle = paste0('pA=',poss_params[[i]][1,2],', pAu=',poss_params[[i]][2,2], 
                         ', pB=',poss_params[[i]][3,2], ', pBu=',poss_params[[i]][4,2]))

pc
#ggsave('~/Documents/GitHub/gw/ccollider12.pdf', width = 7, height = 5, units = 'in')
