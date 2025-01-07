###########################################################################
####################### Collider likelihood  ##############################


# Script to calculate likleihood of data given the model (general light cesm, from `get_model_preds` series)
# Takes data processed in `mainbatch_preprocessing`.

# If the model said eg .3, .2, .2, .3, and we saw a single data point on A, 
# then the likelihood of that data would be .3
# Need to apply this to all the data. The vectors of probability are then the 4 numbers given by the cesm for each (32) world.
# Then we take each data point separately and get its probability? So data doesn't get summed per world



# can do at level of count of ppts, because we don't fit a noise param per ppt. and filter out the ones where model is 0
# so for these 17 ppts, (say) ll is .3^17



# -------------- From elsewhere, modify as need ---------------

# Softmax function 
softmax <- function(x, t)
{
  exp(x/t)/sum(exp(x/t))
}

# Function to output NLL: the most important bit
cesmOther_mod <- function(par, dat, mp) 
{
  tau <- exp(par[1])
  eta <- exp(par[2])
  out <- rep(NA, length = nrow(dat)) 
  for (i in 1:nrow(dat))
  {
    tag <- dat[i,2] 
    case <- mp[mp$tag==tag,]
    CES <- case[3:6] # Get the model predictions of the four existing causes 
    p_outcome <- case[[9]] 
    Other <- (1-p_outcome)*eta # For the 'Flat Other' model here is just eta, meaning a flat constant tendency to say Other
    CESOther <- cbind(CES,Other) # Now we have 5 causes
    these_mp <- softmax(CESOther, tau) # Normalise our 5 causes (but these only live here. The subset dfs still have NAs in Other)
    out[i] <- mean(these_mp[dat[i,5:9]==1]) # Gives c.0.1-0.3, as rows tend to have 1s in 1-3 columns
  }
  
  print(-sum(log(out)))
  
  -sum(log(out), na.rm=T) 
}

# Intermediary step to help set up df to store params
dfnames <- c('s005', 's01', 's015', 's02', 's025', 's03', 's035', 's04', 's045', 's05', 's055', 's06', 's065', 's07', 's075', 's08', 's085', 's09', 's095')

# df to store params
params <- data.frame(ij = 1:19, dfname = dfnames, tau = NA, eta = NA, nll = NA)

# Optimise parameters and put them in the df
for (k in 1:19)
{
  opt <- optim(par = c(1,1), fn = cesmOther_mod, dat = XXX, mp = subsets[[k]])
  p <- exp(opt$par)
  params[k,3] <- p[[1]]
  params[k,4] <- p[[2]]
  params[k,5] <- opt$value
}
