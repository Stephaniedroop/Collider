############################################################### 
###### Collider - save parameters as probability vectors  #####
###############################################################


rm(list=ls())

# All the params we want, put into a list of 4x2 dfs
params1 <- data.frame("0"=c(0.9,0.5,0.2,0.5), "1"=c(0.1,0.5,0.8,0.5))
params2 <- data.frame("0"=c(0.5,0.9,0.5,0.2), "1"=c(0.5,0.1,0.5,0.8))
params3 <- data.frame("0"=c(0.9,0.3,0.2,0.5), "1"=c(0.1,0.7,0.8,0.5))
#params4 <- data.frame("0"=c(0.5,0.5,0.5,0.5), "1"=c(0.5,0.5,0.5,0.5))
#params5 <- data.frame("0"=c(0.5,0.2,0.5,0.9), "1"=c(0.5,0.8,0.5,0.1))
#params6 <- data.frame("0"=c(0.2,0.5,0.9,0.3), "1"=c(0.8,0.5,0.1,0.7))
row.names(params1) <- row.names(params2) <- row.names(params3) <-c ("pA",  "peA", "pB", "peB")
# <- row.names(params4) <- row.names(params5) <- row.names(params6)
names(params1) <- names(params2) <- names(params3) <- c('0','1')
#<- names(params4) <- names(params5) <- names(params6)
poss_params <- list(params1, params2, params3)
# , params4, params5, params6
save(file = '../model_data/params.rdata', poss_params)
#<- row.names(params4) <- names(params4) TOOK OUT PARAMS 4 BECAUSE NOW WE DO IT WITH SENS PARAM