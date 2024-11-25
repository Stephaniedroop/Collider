





# and also if possible the average proportion of responses selecting observed variables vs latent variables, 
# and same for the model to see if there’s an overall bias toward observed vs latent by people?



propLat <- read.csv('../Data/propLat') # This is a small intermediate df saved in `mainbatch_preprocessing.R`
# Redo this without facets, but split out the probgroups, and a separate plot of just single T / F

pl <- ggplot(propLat, aes(x = isLat, y = prop,
                     fill = probgroup)) +
  geom_col(aes(x = isLat, y = prop), alpha = 0.4) +
  facet_wrap(~trialtype) + #, levels = trialvalscvec, labels = fulltrialspecc)~.) + #, scales='free_x'
  #geom_point(aes(x = node3, y = normpred), size=2, alpha=0.4) + # pch=21 matches point to bar
  theme_classic()
  #theme(axis.text.x = element_text(angle = 90)) +
  #guides(fill = guide_legend(override.aes = list(size = 0, alpha=0.4))) +
  #labs(x='Node', y=NULL, fill='Explanation \nselected as \nbest by y% of \nparticipants', 
       #title = paste0('Conjunctive collider: pA=',poss_params[[i]][1,2],', pAu=',poss_params[[i]][2,2], 
                      #', pB=',poss_params[[i]][3,2], ', pBu=',poss_params[[i]][4,2]),
       #subtitle = 'Participant choice (bars) against weighted average \nCESM model prediction (dots)')
pl
