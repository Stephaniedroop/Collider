# Notes
# Do not use



#```{r, echo=FALSE, warning=FALSE} 
nllfull <- combNorm2 %>% filter(s==0.7, sens==0.5) %>% 
  mutate(nll = log(cesm)*n)
temp1 <- nllfull %>% filter(cesm!=c(0,NA,NaN))
newnllfull <- sum(temp1$nll)
ll <- exp(newnllfull)

nll0 <- combNLL0 %>% mutate(nll = log(normed)*n)
temp0 <- nll0 %>% filter(normed!=c(0,NA,NaN))
newnll0 <- sum(temp0$nll)

nlln <- combNLLn %>% mutate(nll = log(normed)*n)
tempn <- nlln %>% filter(normed!=c(0,NA,NaN))
newnlln <- sum(tempn$nll)

# MAYBE DON'T NEED ANY OF THIS, SEEING AS WE HAVE THE SECTION ABOVE

#```





# ------- UNUSED LESION CALCS -----------
# A function to sample by slice_sample a setting of uAuB from each trialtype in each pgroup, by its conditional probability
myFun <- function(df) {
  samp <- df %>% 
    group_by(pgroup, trialtype, node3) %>% 
    slice_sample(n=1, weight_by = meancond)
  samp2 <- samp[,1:4]
  samp2
}

# Run this function n times (change n if you like)
n <- 10
ls <- replicate(n, myFun(les4)) 

# Empty place to store the results
pl <- data.frame(matrix(ncol = 0, nrow = 192)) # 36 if no node3; 192 if yes
# But with the first two bits as standards
pl <- cbind(pl, ls[,1][1], ls[,1][2], ls[,1][3])

# Now unlist the contents of ls into this empty df
# for (i in 1:n) {
#   j <- ls[,i]
#   for (g in 1:length(j)) {
#     h <- j[g]
#     pl <- cbind(pl, h)
#   }
# }

# Now get samples into a df
for (i in 1:n) {
  j <- ls[,i]
  h <- j[4]
  pl <- cbind(pl, h)
}

# Pivot long
pl2 <- pl %>% pivot_longer(cols = -c(pgroup, trialtype, node3)) %>% select(-name)
# Remove 
pl2 <- pl2 %>% group_by(pgroup, trialtype, node3, value) %>% summarise(n=n())
# Then merge the model values back in? 

#### 2. 'Sample unobs according to conditional probability'

modelNorm2, group by pgroup and trialtype but not node3, then uAuB, to get the individual possibilities from which to sample. Then sample one as the likely setting for that whole world. However so far I did not keep the 'tags' of the node settings so that is important.

#### 3. 'What's most likely to have happened?'
Start with modelNorm2 or repurpose from lesion 2.

# LESION 2
# modelNorm2, group by pgroup and trialtype but not node3, then uAuB, to get the individual possibilities from which to sample. Then sample one as the likely setting for that whole world, and then the other vars get their score as usual

# 96 obs of 4
les <- modelNorm2 %>% 
  group_by(pgroup, trialtype, uAuB) %>% 
  summarise(meancesm = mean(meancesm)) %>% 
  filter(uAuB!='NANA') 

# (Later) - guess we do need the node3 as a grouping variable
les3 <- modelNorm2 %>% 
  group_by(pgroup, trialtype, node3, uAuB) %>% 
  summarise(meancesm = mean(meancesm)) %>% 
  filter(uAuB!='NANA') 

# Node3 is removable if the later version doesn't work
justcond <- modelNorm2 %>% 
  group_by(pgroup, trialtype, node3, uAuB) %>% 
  summarise(meancond = mean(cond))

# Now re-merge back in the cond
les2 <- merge(les, justcond, by= c("pgroup", "trialtype", "uAuB")) 
les4 <- merge(les3, justcond, by= c("pgroup", "trialtype", "node3", "uAuB")) # Later version with node3

