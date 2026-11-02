# appendMCP Reproducibility Experiment

This folder contains the baseline study config, five agents' edits for four prompts, and an R script that compares simulated operating characteristics.

## Files

- `baseline/example_study.R`: unedited example configuration.
- `agents/agent_01/` through `agents/agent_05/`: independently generated configuration edits.
- `edit_summary.csv`: concise comparison of the edits.
- `run_experiment.R`: seed check, baseline runs, and agent-config simulations.

## Run in Posit Cloud

1. Open this folder as the project root.
2. Install appendMCP if needed:

   ```r
   install.packages("remotes")
   remotes::install_github("johnsonandjohnson/appendMCP")
   ```

3. Run:

   ```r
   source("run_experiment.R")
   ```

Results are written to `results/`. The script saves the 1,000- and 10,000-simulation baselines, the seed comparison, long and wide agent results, and session/package information.
