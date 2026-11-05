Output from run_experiment.R (Posit Cloud, R 4.6.1, appendMCP 0.3.0)

## Results

Run on Posit Cloud (R 4.6.1, appendMCP 0.3.0). Power is cumulative by analysis; analysis 4 is final.

**Part A — seed.** Two identical runs (10,000 simulations) without a seed differed by up to
0.9 percentage points in power; with `set.seed()` they were identical.

**Part B — AI edits.**
- Requests 1, 2, 4: all five agents made identical edits and got identical results.
- Request 3 ("Set equal weights"): agents split between (1/3, 1/3, 1/3) and (0.5, 0.5, 0).
  EFS power: 48% vs 13% at the first interim, 95% vs 85% at the final analysis.
  CR and OS power changed by ≤0.5 points.
- Request 4 ("Increase the sample size to 660"): agents scaled enrollment; power was unchanged
  vs the original design, and success came 2–3 months earlier.

**Conclusion.** Results are reproducible only with a fixed seed, and AI edits only for precise
instructions. An AI-driven workflow needs the seed stored in the config, the agent to ask when
a request is ambiguous, and human review of the config diff before running.

Full tables: `results/` and `appendMCP_experiment_results.xlsx`.
