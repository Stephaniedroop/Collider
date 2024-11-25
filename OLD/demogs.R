##########################################################################
###########  Collider participant demographics and summary  #############
##########################################################################

# Script to get participant demongraphics, from download csvs from Prolific



library(tidyverse)
rm(list=ls())

setwd("/Users/stephaniedroop/Documents/GitHub/gw/Collider/Main_scripts")
d1 <- read.csv("../Experiment/demogs/colliderdemogs1.csv") # All these ones completed and can stay
d2 <- read.csv("../Experiment/demogs/colliderdemogs2.csv")
d3 <- read.csv("../Experiment/demogs/colliderdemogs3.csv")

# They all have the same variables so can be collated - not d1 for now - add it back later
demogs <- rbind(d2,d3) # 716 of 21

# Now remove the ones who didn't complete the study and didn't get paid 
demogs <- demogs %>% filter(Status=='APPROVED') # Leaves 288

# Some were removed for not completing all 12 trials. We have enough data to be picky.

# Another way: get the datafordemogs (from `mainbatch_preprocessing` and match the ppts IDs
dfdemogs <- read.csv("../Experiment/demogs/datafordemogs.csv") # 3396

# Find who is complete
s12 <- dfdemogs %>% group_by(prolific_id) %>% summarise(n=n()) %>% filter(n==12) # 279 

demogs <- demogs %>% filter(Participant.id %in% s12$prolific_id) # 275


# A list of everyone who did the whole experiment and was approved
demogs <- rbind(demogs, d1) %>% filter(Status=='APPROVED') # 280. Not sure why we have 288 elsewhere. Prob can only keep these ones

# Now for demogs on these:
# Age
demogs$Age <- as.integer(demogs$Age)
max(demogs$Age) # 78
min(demogs$Age) # 18
mean(demogs$Age) # 36.8
sd(demogs$Age) # 12.4

# Time taken
mean(demogs$Time.taken)/60 # 17.67
sd(demogs$Time.taken)/60 # 7.81

demogs %>% group_by(Sex) %>% summarise(n=n())
