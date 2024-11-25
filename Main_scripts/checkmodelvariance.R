# Scrappy checks of sd and mean numnber of cfs, after the Oct24 change to model prediction generation step to now run 10 times and take avergae
# These checks were checked by Neil end Oct24 and we decided the sd etc are fine
# Can come back to if we need to report

library(tidyverse)

all <- read.csv('../model_data/all.csv') %>% replace(is.na(.), 0) # 4032 of 19. now 20160 of 25

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