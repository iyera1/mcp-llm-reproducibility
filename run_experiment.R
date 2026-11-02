# appendMCP reproducibility experiment
# ------------------------------------------------------------------
# Part A: does process_config() give the same operating characteristics
#         (OCs) when run twice? Without a seed vs with set.seed().
# Part B: the same four plain-English change requests were given to five
#         independent Claude agents; each edited the example config.
#         Here every agent's config is simulated under the SAME seed, so
#         any difference in results comes from how the LLM edited the
#         config, not from Monte Carlo noise.
#
# Usage: set appendMCP_repro as the working directory,
#        then source("run_experiment.R"). Results are written to ./results/.
# ------------------------------------------------------------------

# install.packages("remotes")
# remotes::install_github("johnsonandjohnson/appendMCP")
library(appendMCP)

dir.create("results", showWarnings = FALSE)
SEED <- 2026

load_cfg <- function(path) {
  env <- new.env()
  sys.source(path, envir = env)
  get("example_study_config", envir = env)
}

# Overall OCs (Table 6b: probability of rejecting each hypothesis subset, etc.)
oc <- function(cfg, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  res <- process_config(cfg)
  t6 <- as.data.frame(res$tables$table6b)
  data.frame(metric = t6$Metric, subset = t6$`Hypothesis subset`,
             value = t6$Value, stringsAsFactors = FALSE)
}

# Record the environment so the results themselves are reproducible
writeLines(c(capture.output(sessionInfo()),
             paste("appendMCP version:", as.character(packageVersion("appendMCP")))),
           "results/session_info.txt")

# ---------------- Part A: seed ----------------------------------------
base <- load_cfg("baseline/example_study.R")
base$sims <- 10000L

a1 <- oc(base)               # no seed, run 1
a2 <- oc(base)               # no seed, run 2
a3 <- oc(base, SEED)         # seed, run 1
a4 <- oc(base, SEED)         # seed, run 2

partA <- data.frame(metric = a1$metric, subset = a1$subset,
                    no_seed_run1 = a1$value, no_seed_run2 = a2$value,
                    seed_run1 = a3$value,    seed_run2 = a4$value)
partA$diff_no_seed <- partA$no_seed_run1 - partA$no_seed_run2
partA$diff_seed    <- partA$seed_run1 - partA$seed_run2
write.csv(partA, "results/partA_seed.csv", row.names = FALSE)

cat("\nPart A - largest run-to-run difference in any OC\n")
cat("  without seed:", max(abs(partA$diff_no_seed)), "\n")
cat("  with seed:   ", max(abs(partA$diff_seed)), "\n")

# ---------------- Part B: LLM-edited configs ---------------------------
# Save the unedited design at both simulation counts used by the requests.
baseline_1000 <- oc(load_cfg("baseline/example_study.R"), SEED)
write.csv(baseline_1000, "results/partB_baseline.csv", row.names = FALSE)

baseline_10000_cfg <- load_cfg("baseline/example_study.R")
baseline_10000_cfg$sims <- 10000L
baseline_10000 <- oc(baseline_10000_cfg, SEED)
write.csv(baseline_10000, "results/partB_baseline_10000.csv", row.names = FALSE)

partB <- list()
request_names <- c("events_sims", "hazard_ratio", "weights", "enrollment")
for (agent in 1:5) {
  for (request in 1:4) {
    f <- file.path("agents", sprintf("agent_%02d", agent),
                   sprintf("request_%02d_%s.R", request, request_names[request]))
    out <- tryCatch({
      tab <- oc(load_cfg(f), SEED)
      data.frame(agent = agent, request = request, status = "ok", tab)
    }, error = function(e) {
      data.frame(agent = agent, request = request,
                 status = paste("ERROR:", conditionMessage(e)),
                 metric = NA, subset = NA, value = NA)
    })
    partB[[length(partB) + 1]] <- out
    cat("agent", agent, "request", request, ":", out$status[1], "\n")
  }
}
partB <- do.call(rbind, partB)
write.csv(partB, "results/partB_llm_runs_long.csv", row.names = FALSE)

# Wide view: one row per request x metric, one column per agent.
partB_ok <- subset(partB, status == "ok")
wide <- reshape(partB_ok[, c("request", "metric", "subset", "agent", "value")],
                idvar = c("request", "metric", "subset"),
                timevar = "agent", direction = "wide")
run_cols <- grep("^value", names(wide))
wide$spread <- apply(wide[, run_cols, drop = FALSE], 1,
                     function(x) diff(range(x, na.rm = TRUE)))
write.csv(wide, "results/partB_llm_runs_wide.csv", row.names = FALSE)

cat("\nPart B - largest spread across the five agents, by request\n")
print(aggregate(spread ~ request, data = wide, FUN = max))
