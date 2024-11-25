#################################################### 
###### Collider - plots of model predictions  #####
####################################################


rm(list=ls()) 
# Load
load('../model_data/params.rdata', verbose = T) # defined in script `set_params.r`
source('collider_plot_a.R') # A script with some ggplot calls
data <- read.csv('../model_data/tidied_preds.csv') # From script `modpred_processing.r`

# Pull out what we need for plotting
# Actually need to save 'forplotd' in a list for each params -- TO DO 


for (i in 1:length(poss_params)) { 
  
  # One way of charting the possible values of the unobserved variables, saved under `i`
  # eg 'da1' is disjunctive actual , params setting 1
  dchart <- paste0('~/Documents/GitHub/gw/Collider/figs/model_preds/','da',i,'.pdf')
  ggsave(dchart, plot=pd, width = 7, height = 5, units = 'in')
  cchart <- paste0('~/Documents/GitHub/gw/Collider/figs/model_preds/','ca',i,'.pdf')
  ggsave(cchart, plot=pc, width = 7, height = 5, units = 'in')
  
  # Important to find the right piece of the model predictions - what do we want to do with it?
  # assuming wa (in unobs_a, saved as wad/wac)
}

# Save 
save(mod_preds, file='../model_data/modpreds.Rdata')