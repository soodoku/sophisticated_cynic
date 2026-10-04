source("R/data.R")
source("R/analysis.R")
dir.create("tabs", showWarnings = FALSE)
dir.create("data/derived", recursive = TRUE, showWarnings = FALSE)
raw <- read_sources()
d <- build_data(raw$full, raw$matched$caseid)
stopifnot(nrow(d) == nrow(raw$full), !anyDuplicated(d$caseid))
utils::write.csv(d, "data/derived/respondents.csv", row.names = FALSE, na = "")
write_csv(data_dictionary(raw$full), "dictionary")
paths <- c(source_paths(), list.files("data/cces", "txt$", full.names = TRUE))
write_csv(data.frame(
  file = paths, bytes = file.info(paths)$size,
  sha256 = vapply(paths, digest::digest, character(1), algo = "sha256", file = TRUE)
), "source_manifest")

flow <- do.call(rbind, lapply(c("full", "matched"), function(s) {
  x <- if (s == "full") d else d[d$matched, ]
  do.call(rbind, lapply(1:2, function(o) {
    do.call(rbind, lapply(0:1, function(z) {
      a <- x[x$order == o & x$bad == z, ]
      data.frame(
        sample = s, order = o, arm = a$arm[1], assigned_n = nrow(a),
        sophistication_n = sum(!is.na(a$sophistication)),
        belief_n = sum(!is.na(a$bad_belief)),
        unexpected_missing_n = sum(is.na(a$sophistication) & a$asked_sophistication)
      )
    }))
  }))
}))
write_csv(flow, "sample_flow")
a <- d[d$asked_sophistication, ]
m <- a[a$matched, ]
stopifnot(nrow(a) == 711L, nrow(m) == 505L)
stopifnot(!anyNA(a[c("sophistication", "age", "female", "college", "white", "party")]))
summaries <- rbind(
  cbind(sample = "Full sample", arm_summary(a)),
  cbind(sample = "Matched subset", arm_summary(m)),
  cbind(sample = "Matched weighted", arm_summary(m, TRUE))
)
write_csv(summaries, "arm_means")
adjusted <- fit_adjusted(a)
weighted <- stats::lm(sophistication ~ bad, m, weights = weight)
rounded <- c(100, 83, 66, 50, 33, 16, 0)[a$score_code]
estimates <- rbind(
  cbind(specification = "Full sample", mean_difference(a$sophistication, a$bad)),
  cbind(specification = "Covariate adjusted", model_result(adjusted)),
  cbind(specification = "Matched subset", mean_difference(m$sophistication, m$bad)),
  cbind(specification = "Matched weighted", model_result(weighted)),
  cbind(specification = "Rounded scale", mean_difference(rounded, a$bad)),
  cbind(specification = "Unmatched remainder", mean_difference(
    a$sophistication[!a$matched], a$bad[!a$matched]
  ))
)
write_csv(estimates, "estimates")
write_csv(permutation_test(a$sophistication, a$bad), "permutation")
write_csv(influence_summary(a, stats::lm(sophistication ~ bad, a)), "influence")
write_csv(influence_summary(a, adjusted), "adjusted_diagnostics")
write_csv(influence_summary(m, weighted), "weighted_diagnostics")
write_csv(balance_summary(a), "balance")
write_csv(threshold_summary(a), "thresholds")
write_csv(subgroup_summary(a), "interactions")

distribution <- as.data.frame(table(arm = a$arm, score_code = factor(a$score_code, levels = 1:7)))
names(distribution)[3] <- "n"
distribution$pct <- 100 * distribution$n / ave(distribution$n, distribution$arm, FUN = sum)
write_csv(distribution, "distribution")
selection <- do.call(rbind, lapply(0:1, function(z) {
  x <- a[a$bad == z, ]
  data.frame(
    arm = x$arm[1], n = nrow(x), matched_n = sum(x$matched),
    matched_pct = 100 * mean(x$matched)
  )
}))
write_csv(selection, "selection")
write_csv(mean_difference(100 * as.integer(a$matched), a$bad), "selection_difference")
write_csv(mean_difference(100 * as.integer(d$asked_sophistication), d$bad), "routing_difference")

belief <- d[d$order == 2, ]
samples <- c("Full sample", "Matched subset", "Matched weighted")
belief_summary <- do.call(rbind, lapply(samples, function(s) {
  x <- if (s == "Full sample") belief else belief[belief$matched, ]
  w <- if (s == "Matched weighted") x$weight else rep(1, nrow(x))
  fit <- stats::lm(bad_belief ~ 1, x, weights = w)
  se <- sqrt(sandwich::vcovHC(fit, type = "HC3")[1, 1])
  avg <- stats::weighted.mean(x$bad_belief, w)
  data.frame(
    sample = s, n = nrow(x), bad_n = sum(x$bad_belief), bad_pct = 100 * avg,
    lower = 100 * (avg - stats::qt(0.975, nrow(x) - 1) * se),
    upper = 100 * (avg + stats::qt(0.975, nrow(x) - 1) * se)
  )
}))
write_csv(belief_summary, "beliefs")

rank_test <- stats::wilcox.test(sophistication ~ bad, a, exact = FALSE, correct = TRUE)
pairwise <- outer(a$sophistication[a$bad == 1], a$sophistication[a$bad == 0], "-")
write_csv(data.frame(
  bad_higher_probability = mean(pairwise > 0) + 0.5 * mean(pairwise == 0),
  wilcoxon_p = rank_test$p.value,
  bad_median = stats::median(a$sophistication[a$bad == 1]),
  good_median = stats::median(a$sophistication[a$bad == 0])
), "ordinal")
write_csv(data.frame(
  sample = c("Full sample", "Matched subset"),
  n = c(nrow(d), sum(d$matched)),
  start = c(min(d$start_date), min(d$start_date[d$matched])),
  end = c(max(d$start_date), max(d$start_date[d$matched])),
  joint_outcomes_n = sum(!is.na(d$sophistication) & !is.na(d$bad_belief))
), "inventory")
capture.output(utils::sessionInfo(), file = "tabs/session_info.txt")
print(estimates, row.names = FALSE)
