# The curious case of the COLLIDER

Started as a simplified test case for the Social Explanations in Gridworlds project but has grown to a full project in its own right.

_NOTE: this is work in progress! The master script won't yet run all analyses out of the box, but it's still the best place to see my most recent work. I should have a paper preprint in January 2025._

## How to run

You can see the behavioural experiment at https://eco.ppls.ed.ac.uk/~s0342840/collider/collidertop.html. Code for the task interface and structure of running it in JavaScript in in the folder `Experiment`. To click through the experiment: at the comprehension check enter Yes, No, True, 12.

## Authors

- Stephanie Droop (stephanie.droop@ed.ac.uk)
- Neil Bramley
- Tadeg Quillien
- Christopher Lucas

## What is a Collider and why is it important?

When two possible causes, A and B, can both cause effect E. It can be either conjunctive (A _and_ B needed for E) or disjunctive (A _or_ B needed for E). It's a good toy scenario to get a model working. It seems that when several things can potentially cause an outcome, and people want to decide what specifically caused it _this time_, they pick the thing that reliably occurs at the same time as the effect.

But the world is messy and things don't stay the same for long enough to really count everything up. We often have to explain events without having had the luxury of running a proper randomised controlled experiment. Somehow we all do manage to do this, and well enough not to notice how remarkable it is! One theory of how we do this is that our minds simulate `counterfactuals`, (aka other ways things could have turned out), under the hood, under our conscious awareness. Under this theory, we imagine other similar situations, and we decide something is a cause when it robustly correlates with the effect even as everything around shifts and changes. This is elegantly modelled in Quillien's `counterfactual effect size model`, which went a step further than the other existing accounts like Lewis `direct dependency` (where literally everything else has to stay the same to calculate a cause's strength, ie. it only goes 'one layer deep') and Icard/Morris necessity-sufficiency model. Quillien's model 'jiggles', 'flips' or 'resamples' all the variables just like things vary in real life, and then calculates how invariant the cause is across these counterfactuals.

However elegant this model is, it can't be the whole story. The causal score it allocates is only based on base rate or probability, whereas people are more sensitive to the structure they see in the world. It seems we naturally gravitate to causes that are more informative. THat's what this project is about, to model how we do that.

## Files, folders, model etc

### FOLDER Main_scripts

#### Core

- `masterscript.R` - top level script to wrangle and process the participant data, run the CESM to get model predictions and save them in folder `model_data`, run other mdoel lesions, check model fit, plot all charts, etc. Not yet working out of the box, but best place to see the structure.
- `mainbatch_preprocessing.R` - get the participants' behavioural experiment data ready.
- `functions.R` - static script of functions used to set up the worlds and run the CESM model
- `set_params.R` - small script to set the different probabilities we want to manipulate for the model and experiment
- `get_model_preds2.R` - get model predictions
- `combine_ppt_with_preds.R` - combine predictions with participant data
- `combine_lesions.Rmd`, `combine_per_s_oldplots.Rmd`, `combine_per_s.Rmd`, `combine_sens.Rmd`, `combine_summary_plots.Rmd`, `lesions_and_NLL.Rmd` - all these generate html pages to visualise the model predictions against the participant data, for each of the different parameter combinations. WIP. Undecided what will form narrative flow of paper. Masterscript takes precedence.
- `modpred_processing.R` and any other variant that starts 'modpred_process...' - some model lesions do not require a full rerun of the cesm model but can be done post hoc by cutting or changing parts of how the model scores and probabilities are normalised, conditioned on, inferred, or otherwise combined and used. WIP.

#### Non-core

- `cesmheavyfunc.R` - an older, heavier, learning version of the CESM model, where everything is defined as variables and pulled out as dataframe rows. Can be easier to read.
- `check_preds_plot.R` - probably won't end up using
- `check_model_variance.R` - just a check that 10 runs of the model produce predictions with acceptable variance (they do).

### FOLDER Experiment

Holds the Javascript and html to run the behavioural experiment, which is an online interface with a task like a game. Participants from Prolific were paid to complete the task in early July 2024.

### FOLDER Data, pilot_data

Participant data from the behavioural experiment. dfhdkj

### FOLDER Model_data, processed_data

Holds the intermediary participant data in a form ready to be compared with model predictions, and those model predictions. Best loaded and inspected via the scripts called in `masterscript.R`.

### FOLDER OLD, Other

Self explanatory - a big ol' mess. Once the project is ready to publish I will tidy up.

## Glossary

Some everyday words have a special sense in this project.

- `world` - a setting of node variables A and B, and outcome E, a single iteration of how things started off and turned out. Each node can take 0 or 1. Sometimes represented by the values of A,B,E in order, eg. 110 means A=1, B=1, E=0, or that A and B both happened and the effect didn't.
-
