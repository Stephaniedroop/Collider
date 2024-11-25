


data1 <- read.csv('../data1.csv') # 1745 of 19


# also need to mix around some actual conditions

# I think for c1,c4, c5, d1, d6, d7, we can just switch the answers
# But for the others, for TRIALTYPE, they have to be changed as follows:
# c2 goes to c3
# c3 goes to c2
# d2 goes to d4
# d3 goes to d5
# d4 goes to d2
# d5 goes to d3

# To do this, we'll take an intermediate column and then start replacing values
data1$cbtt <- data1$trialtype
data1$cbtt[data1$trialtype=='c2'] <- 'c3'
data1$cbtt[data1$trialtype=='c3'] <- 'c2'
data1$cbtt[data1$trialtype=='d2'] <- 'd4'
data1$cbtt[data1$trialtype=='d3'] <- 'd5'
data1$cbtt[data1$trialtype=='d4'] <- 'd2'
data1$cbtt[data1$trialtype=='d5'] <- 'd3'
           


# Now we can flip all the answers
# Store indices of which answers are already a and which are b
aans <- as.vector(1:4)
bans <- as.vector(5:8)

data1 <- data1 %>% mutate(anscb = if_else(ans %in% aans, ans+4, ans-4))
data1 <- data1 %>% select(-c(trialtype,ans)) %>% rename(trialtype = cbtt, ans = aans)

# Now copy this back to the main script

