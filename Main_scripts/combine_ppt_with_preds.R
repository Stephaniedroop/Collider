#################################################### 
###### Collider analysis - compare model preds #####
####################################################

# Script takes the processed data from the collider ppt expt (`DATA.RDATA`)
# (which was cleaned and sliced in `mainbatch_preprocessing.R`) 

# and combines it with the preprocessed model predictions from `modpred_process_allmodules.R` (`tidied_preds3.csv` and split rdata)


library(tidyverse)
library(ggnewscale) 
library(ggpmisc)
#library(psych) # For if we want to use phi
#library(shiny)
rm(list=ls())


s_vals <- c(seq(0.6, 0.95, 0.05), seq(0.96, 0.99, 0.01)) 

# Generate .Rmd report for each value of s
lapply(s_vals, function(s) {
  rmarkdown::render("combine_per_s.Rmd", 
                    output_file = paste0(s, "_report.html"),
                    params = list(s = s))
})


# People may be sensitive to probabilities in some situations only - in some contexts, or to some vars in some worlds
# Maybe they sensitive only to: probs of unobserved vars when the observs are ON
# Maybe remove the probs to the conj000 where people might be sensitive in the opposite way to what the model predicts

# Generate new series of RMarkdown reports with lesions - still not sure how best to structure
lapply(unique(s_vals), function(stab.i) {
  rmarkdown::render(input = 'combine_lesions.Rmd',
                    params = list(stab = stab.i),
                    output_file = paste0(stab.i, 'lesions.html'))
  
})
