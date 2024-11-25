# COLLIDER - intermediate testcase for model with unobserved variables

A sub-readme for a subfolder of gw

## Part of the Social Explanations in gridworlds project

## Authors

- Stephanie Droop (stephanie.droop@ed.ac.uk)
- Neil Bramley
- Tadeg Quillien
- Christopher Lucas

Code for online behavioural experiment in js run May-June 2024 kept in other Gridworld local folder, eventually put on here too?

## How to run

`masterscript.R` - top level script to run cesm to get model predictions and save them in folder `model_data`. It runs the 'actual causation' version, see below in Scripts section for details. To do without actual causation, rerun masterscript.

Model predictions calculated for parameter settings (ie. base rate probabilities of observed nodes and unobserved noise nodes).

The ones used were, in order A,Au,B,Bu:
['10%', '50%', '80%', '50%'], // 2 in data and powerpoint but called 1 here
['50%', '10%', '50%', '80%'], // 1 in data and powerpoint but called 2 here
['10%', '70%', '80%', '50%'], // 11 in data and powerpoint but called 3 here

- Then into `model_preds` (list) of dfs for the 3 param setting. Inside each 3 bins is:
- [[]][[1]]: dfd
- [[]][[2]]: dfc
- [[]][[3]]: forplotd
- [[]][[4]]: forplotc
- [[]][[5]]:
- [[]][[6]]:

These are collated with participant data in an R script `collider_analysis.R'. (TO DO)

This folder also contains graphics generated in turn for disjunctive and conjunctive settings.

## Notes for how to read dataframes

### Trialtypes

(Note)
A/B/E
Conj:
000: c1
010: c2
100: c3
110: c4
111: c5

Disj:
000: d1
010: d2
011: d3
100: d4
101: d5
110: d6
111: d7

### Guide to the different probabilities and model predictions used

- `cond` - normalised marginal probability distribution within each group or trialtype ('poss$Pr/sum(poss$Pr)'). Sums to 1 within each trialtype.
- `cp` - the original cesm counterfactual effect size calculated for each of the four variables in the general_cesm funtion, and saved in dfs called eg. 'mp1d'. Cols 2:5 in alld and allc. The points in the figures.
- `wa` - each cp multiplied by cond. Became cols 14:17 in alld/allc. Called this for 'weighted average' although it isn't combined yet, that came in the ggplot call. The column in the figures, the average of the point.

## pilot_data

First 5 with their separate preprocessing script and second ten with preprocessing script changed over from local folder 25 Jun 2024

## Scripts

### Actual causation version - removing causes meaningless for outcome

It is meaningless to assign a causal score to a variable with a setting that can not give rise to the effect and so these must be removed manually or on the heuristic "Do not assign score for C=! E". (Quillien).

- `general_cesm_a.R` Script for general counterfactual model. A function takes arguments of causal variables with prior strengths, loops over observations and calculates causal responsibility of each variable across counterfactual worlds. The actual causation (Halpern) version. This is script 1 of 3 for the Spring 2024 collider setting. Made of two functions: world_combos and general_cesm
- `unobs_a.R` - Script to calculate marginal and weighted average counterfactual effect size of the unobserved variables. Takes as input the outputs of the `general_cesm_a.R` i.e. loads the probabilities of the 4 cause vars, the world combos in disjunctive and conjunctive collider settings, and model predictions for each. Gives as output the model's counterfactual effect size for each node in each world.
- `collider_plot_a.R` - Script to plot model predictions for collider of two observed variables (A and B), and two unobserved noise variables of A and B (Au and Bu). In all three scripts, set parameters by hand and run all three to plot the model predictions at that setting.

### Same but not using Halpern actual causation -- i.e. can assign a causal score to impermissable causes

- `general_cesm.R` Script for general counterfactual model. A function takes arguments of causal variables with prior strengths, loops over observations and calculates causal responsibility of each variable across counterfactual worlds.
- `unobs.R`
- `collider_plot.R`
