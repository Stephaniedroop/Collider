# Script takes the processed data from the collider ppt expt (`DATA.RDATA`)
# (which was cleaned and sliced in `mainbatch_preprocessing.R`) 
# and combines it with the preprocessed model predictions from `modpred_processing1.R` (`tidied_preds3.csv` or split by s val)


# Load ppt data and model predictions
load('../Data/Data.Rdata', verbose = T) # This is one big df, 'data', 3408 obs of 18 ie. 284 ppts
load(file = paste0('../model_data/', s ,'model.rdata'))

# Assign as factors
mp$pgroup <- as.factor(mp$pgroup)
mp$node3 <- as.factor(mp$node3)
mp$trialtype <- as.factor(mp$trialtype)
mp$sens <- as.factor(mp$sens)
mp$structure <- as.factor(mp$structure)
mp$E <- as.factor(mp$E)

# For ACTUAL CAUSATION - some variables must be set to 0 if they are inconsistent with outcome 
# (eg A=0 cannot be a cause of E=1 )

# mp$cp[mp$vA!=mp$E & mp$node2=='A'] <- 0
# mp$cp[mp$vAu!=mp$E & mp$node2=='Au'] <- 0
# mp$cp[mp$vB!=mp$E & mp$node2=='B'] <- 0
# mp$cp[mp$vBu!=mp$E & mp$node2=='Bu'] <- 0


# For scatter to see if grouping falls naturally when by E. This way doesn't give all combos (ie gives NAs) but ok here? NEW VERSION WITH E  
modelNorm <- mp %>%  # 384
  group_by(sens, pgroup, trialtype, E, node3, uAuB, cond) %>% # guess it's ok to not have .drop=F
  summarise(meancesm = mean(cp)) %>%  # take the mean of the 10 model runs
  mutate(intermed = meancesm*cond) %>% 
  group_by(sens, pgroup, trialtype, E, node3) %>% 
  summarise(wa = sum(intermed)) %>% 
  mutate(normed = round(wa/sum(wa, na.rm = T),3))


# An odd little way to bring in realLat status, must be a better way
modelPlaceholder <- mp %>% 
  na.omit() %>% 
  group_by(sens, pgroup, trialtype, node3, realLat, isLat, .drop = FALSE) %>% 
  tally

# For realLat, everything TRUE has been defined as such. 
# Everything else needs to be FALSE (currently some are na because we used .drop=F to get all the combinations).
modelPlaceholder$realLat <- modelPlaceholder$realLat %>% replace(is.na(.), FALSE)
modelPlaceholder$isLat <- modelPlaceholder$isLat %>% replace(is.na(.), FALSE)
modelPlaceholder <- modelPlaceholder %>% select(-n)
#modelPlaceholder2 <- modelPlaceholder2 %>% replace(is.na(.), FALSE) %>% select(-n)

modelNorm <- merge(modelNorm, modelPlaceholder)
modelNorm <- modelNorm[, c(2:4, 6:9, 5, 1)]
#modelNorm2 <- merge(modelNorm, modelPlaceholder2)
#modelNorm0 <- merge(modelNorm0, modelPlaceholder)

# Put a column with structure - for some reason it doesn't have
modelNorm <- modelNorm %>% 
  mutate(structure = if_else(grepl("^c", trialtype), 'conjunctive', 'disjunctive'),
         vartype = if_else(grepl(c("^Au|^Bu"), node3), 'un', 'obs'),
         a1 = if_else(trialtype %in% c('c5', 'd7'), 'TRUE', 'FALSE'),
         inf = if_else(realLat=='FALSE' & isLat=='TRUE', 'TRUE', 'FALSE'))


# ------------- 2. Summarise participant data in same format ---------------------
# Section to get all combinations of variables, left join the participant answers of each, 
# and tag those with whether their answers are coherent or not (isPerm)


# First set factors so we can use tally
data$pgroup <- as.factor(data$pgroup)
data$node3 <- as.factor(data$node3)
data$trialtype <- as.factor(data$trialtype)
data$isPerm <- as.factor(data$isPerm) # this is per actual causation (PossAns in the json)

# Some confusion over whether we want realLat or isPerm - and how to feed those things to the chart later
# We want both. realLat applies to both model and data, so is tagged here to model.
# isPerm is a data value so is tagged here to data. The combnorm takes them both to variable settings

# Bring in the isPerm status of all the node answers actually given
dataPlaceholder <- data %>% # 214
  na.omit() %>% 
  group_by(pgroup, trialtype, node3, isPerm) %>% # prob no need for .drop because the isPerm val is the same for both values of the var
  tally

dataNorm <- data %>% # 289
  group_by(pgroup, trialtype, node3, .drop=FALSE) %>% # Here we do need the .drop to get all the combinations
  tally %>% 
  mutate(prop=n/sum(n))

# Merge and keep all the 288 combinations, adding the isPerm vals for the ones that got an answer
dataNorm <- merge(x=dataNorm, y=dataPlaceholder, all.x = T) %>% replace(is.na(.), FALSE) %>% select(1,2,3,6,4,5)
# This then used for likelihood calc

# BUT WE DECIDED WE WON'T FILTER BY ISPERM... still, it doesn't matter we tagged it here


# ----------- 3. The actual merge! ------------ 
# A longer version, where both cesm and ppts are long, by '%'
combNorm <- merge(x=dataNorm, y=modelNorm) %>% # , by=c('pgroup', 'trialtype', 'node3')
  select(-wa, -n) %>% # Probably don't remove - need for lik
  rename(cesm=normed, ppts=prop) %>%
  pivot_longer(cols = cesm:ppts, values_to = 'percent')

# One for the scatter plots: a bit wider
combNorm2 <- merge(x=dataNorm, y=modelNorm) %>% 
  select(-wa, -n) %>% 
  rename(cesm=normed, ppts=prop) %>% 
  filter(isPerm==TRUE)

# One without the filter
combNorm3 <- merge(x=dataNorm, y=modelNorm) %>% 
  select(-wa, -n) %>% 
  rename(cesm=normed, ppts=prop) 

save(combNorm3, combNorm2, combNorm, dataNorm, modelNorm, file = paste0('../processed_data/', s, 'comb_noact.Rdata'))
#save(file = '.rdata', pChoice)