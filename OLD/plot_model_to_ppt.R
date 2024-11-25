#################################################### 
###### Collider - plot model preds with ppts  #####
####################################################

# Actual plotting is done in a function in the masterscript??? no

# Notes on chart
# If we normalised the bars then it would give the prob matching approach. 
# Need no y axis because it suggests probability when it isn't
# Try normalised so it becomes probability, then plot ppt against this. 
# (For real thing it will have optimised softmax temp but at least we can see)

rm(list=ls())

# get params
load('../model_data/params.rdata', verbose = T) # saved in `get_model_preds.R`
load('../processed_data/fp.rdata', verbose = T) # saved in `combine_ppt_with_preds.R`

# Define function to plot % ppts choosing answer as primary explanation against normalised model pred wa

plot_to_ppt_d <- function(df) {
  pd <- ggplot(df, aes(x = node3, y = prop,
                   fill = node3)) +
    geom_col(aes(x = node3, y = prop), alpha = 0.4) +
    facet_wrap(factor(trialtype, levels = trialvalsdvec, labels = fulltrialspecd)~.) + #, scales='free_x'
    geom_point(aes(x = node3, y = normpred), size=2, alpha=0.4) + # pch=21 matches point to bar
    theme_classic() +
    theme(axis.text.x = element_text(angle = 90)) +
    guides(fill = guide_legend(override.aes = list(size = 0, alpha=0.4))) +
    labs(x='Node', y=NULL, fill='Explanation \nselected as \nbest by y% of \nparticipants', 
         title = paste0('Disjunctive collider: pA=',poss_params[[i]][1,2],', pAu=',poss_params[[i]][2,2], 
                        ', pB=',poss_params[[i]][3,2], ', pBu=',poss_params[[i]][4,2]),
        subtitle = 'Participant choice (bars) against weighted average \nCESM model prediction (dots)')
  pd
}


plot_to_ppt_c <- function(df) {
  pc <- ggplot(df, aes(x = node3, y = prop,
                       fill = node3)) +
    geom_col(aes(x = node3, y = prop), alpha = 0.4) +
    facet_wrap(factor(trialtype, levels = trialvalscvec, labels = fulltrialspecc)~.) + #, scales='free_x'
    geom_point(aes(x = node3, y = normpred), size=2, alpha=0.4) + # pch=21 matches point to bar
    theme_classic() +
    theme(axis.text.x = element_text(angle = 90)) +
    guides(fill = guide_legend(override.aes = list(size = 0, alpha=0.4))) +
    labs(x='Node', y=NULL, fill='Explanation \nselected as \nbest by y% of \nparticipants', 
         title = paste0('Conjunctive collider: pA=',poss_params[[i]][1,2],', pAu=',poss_params[[i]][2,2], 
                        ', pB=',poss_params[[i]][3,2], ', pBu=',poss_params[[i]][4,2]),
         subtitle = 'Participant choice (bars) against weighted average \nCESM model prediction (dots)')
  pc
}

# Now call functions for the 3 prob vectors for c and d
# Don't know how to call separately, will just do it manually

# 1.................
i <- 1
pd1 <- plot_to_ppt_d(fp1d)
dchart <- paste0('../figs/model_preds/dmodtoppt1.pdf')
ggsave(dchart, plot=pd1, width = 7, height = 5, units = 'in')

pc1 <- plot_to_ppt_c(fp1c)
cchart <- paste0('../figs/model_preds/cmodtoppt1.pdf')
ggsave(cchart, plot=pc1, width = 7, height = 5, units = 'in')

# 2................
i <- 2
pd2 <- plot_to_ppt_d(fp2d)
dchart <- paste0('../figs/model_preds/dmodtoppt2.pdf')
ggsave(dchart, plot=pd2, width = 7, height = 5, units = 'in')

pc2 <- plot_to_ppt_c(fp2c)
cchart <- paste0('../figs/model_preds/cmodtoppt2.pdf')
ggsave(cchart, plot=pc2, width = 7, height = 5, units = 'in')

# 3................
i <- 3
pd3 <- plot_to_ppt_d(fp3d)
dchart <- paste0('../figs/model_preds/dmodtoppt3.pdf')
ggsave(dchart, plot=pd3, width = 7, height = 5, units = 'in')

pc3 <- plot_to_ppt_c(fp3c)
cchart <- paste0('../figs/model_preds/cmodtoppt3.pdf')
ggsave(cchart, plot=pc3, width = 7, height = 5, units = 'in')


# 4.................
i <- 4
pd4 <- plot_to_ppt_d(fp4d)
dchart <- paste0('../figs/model_preds/dmodtoppt4.pdf')
ggsave(dchart, plot=pd4, width = 7, height = 5, units = 'in')

pc4 <- plot_to_ppt_c(fp4c)
cchart <- paste0('../figs/model_preds/cmodtoppt4.pdf')
ggsave(cchart, plot=pc4, width = 7, height = 5, units = 'in')

# 5................
i <- 5
pd5 <- plot_to_ppt_d(fp5d)
dchart <- paste0('../figs/model_preds/dmodtoppt5.pdf')
ggsave(dchart, plot=pd5, width = 7, height = 5, units = 'in')

pc5 <- plot_to_ppt_c(fp5c)
cchart <- paste0('../figs/model_preds/cmodtoppt5.pdf')
ggsave(cchart, plot=pc5, width = 7, height = 5, units = 'in')

# 6................
i <- 6
pd6 <- plot_to_ppt_d(fp6d)
dchart <- paste0('../figs/model_preds/dmodtoppt6.pdf')
ggsave(dchart, plot=pd6, width = 7, height = 5, units = 'in')

pc6 <- plot_to_ppt_c(fp6c)
cchart <- paste0('../figs/model_preds/cmodtoppt6.pdf')
ggsave(cchart, plot=pc6, width = 7, height = 5, units = 'in')




# for (i in 1:length(poss_params)) { 
#   toplotd <- paste0('fp',i,'d')
#   pd <- plot_to_ppt_d(toplotd)
#   dchart <- paste0('~/Documents/GitHub/gw/Collider/figs/model_preds/','dmodtoppt',i,'.pdf')
#   ggsave(dchart, plot=pd, width = 7, height = 5, units = 'in')
#   pc <- plot_to_ppt_c(paste0('fp',i,'c'))
#   cchart <- paste0('~/Documents/GitHub/gw/Collider/figs/model_preds/','cmodtoppt',i,'.pdf')
#   ggsave(cchart, plot=pc, width = 7, height = 5, units = 'in')
# }
