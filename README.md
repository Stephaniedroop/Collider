# The curious case of the COLLIDER

Started as a simplified test case for the Social Explanations in Gridworlds project but has grown to a full project in its own right.

## Authors

- Stephanie Droop (stephanie.droop@ed.ac.uk)
- Neil Bramley
- Tadeg Quillien
- Christopher Lucas

## What is a Collider and why is it important?

When two possible causes, A and B, can both cause effect E. It can be either conjunctive (A and B needed for E) or disjunctive (A or B needed for E). It's a good toy scenario to get your model working. It seems that when several things can potentially cause an outcome, and people want to decide what specifically caused it _this time_, they pick the thing that reliably occurs at the same time as the effect.

But the world is messy and things don't stay the same for long enough to really count everything up. We often have to explain events without having had the luxury of running a proper randomised controlled experiment. Somehow we all do manage to do this, and well enough not to notice how remarkable it is! One theory of how we do this is that our minds simulate `counterfactuals`, (aka other ways things could have turned out), under the hood, under our conscious awareness. Under this theory, we imagine other similar situations, and we decide something is a cause when it robustly correlates with the effect even as everything around shifts and changes. This is elegantly modelled in Quillien's `counterfactual effect size model`, which went a step further than the other existing accounts like Lewis `direct dependency` (where literally everything else has to stay the same to calculate a cause's strength, ie. it only goes 'one layer deep') and Icard/Morris necessity-sufficiency model. Quillien's model 'jiggles', 'flips' or 'resamples' all the variables just like things vary in real life, and then calculates how invariant the cause is across these counterfactuals.

However elegant this model is, it can't be the whole story. The causal score it allocates is only based on base rate or probability, whereas people are more sensitive to the structure they see in the world. It seems we naturally gravitate to causes that are more informative. THat's what this project is about, to model how we do that.

_NOTE: this is work in progress! I'm currently working on the model lesions at November 2024. I should have a paper preprint in January 2025._

## How to run

You can see the behavioural experiment at https://eco.ppls.ed.ac.uk/~s0342840/collider/collidertop.html. Code for the task interface and structure of running it in js in in the folder `Experiment`.

## Files, folders, model etc

### Main_scripts

- `masterscript.R` - top level script to wrangle and process the participant data, run the CESM to get model predictions and save them in folder `model_data`, run other mdoel lesions, check model fit, plot all charts, etc.
