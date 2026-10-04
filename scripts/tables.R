source("R/data.R")
read_table <- function(name) read.csv(file.path("tabs", paste0(name, ".csv")))
est <- read_table("estimates")
means <- read_table("arm_means")
flow <- read_table("sample_flow")
ordinal <- read_table("ordinal")
perm <- read_table("permutation")
influence <- read_table("influence")
belief <- read_table("beliefs")
threshold <- read_table("thresholds")
selection <- read_table("selection")
balance <- read_table("balance")

fmt <- function(x, digits = 1) formatC(x, digits = digits, format = "f")
ci <- function(x) paste0("[", fmt(x$lower), ", ", fmt(x$upper), "]")
main <- est[est$specification == "Full sample", ]
adjusted <- est[est$specification == "Covariate adjusted", ]
weighted <- est[est$specification == "Matched weighted", ]
subset_est <- est[est$specification == "Matched subset", ]
remainder <- est[est$specification == "Unmatched remainder", ]
good <- means[means$sample == "Full sample" & means$arm == "Good people", ]
bad <- means[means$sample == "Full sample" & means$arm == "Bad people", ]
values <- c(
  FullN = sum(flow$assigned_n[flow$sample == "full"]),
  MatchedN = sum(flow$assigned_n[flow$sample == "matched"]),
  RatingN = main$n, BeliefN = belief$n[1],
  MatchedRatingN = subset_est$n, GoodN = good$n, BadN = bad$n,
  GoodMean = fmt(good$mean), BadMean = fmt(bad$mean),
  MainEstimate = fmt(main$estimate), MainCI = ci(main),
  MainSE = fmt(main$se, 2), MainP = fmt(main$p, 5),
  CategoryDifference = fmt(main$estimate * 6 / 100, 2),
  AdjustedEstimate = fmt(adjusted$estimate), AdjustedCI = ci(adjusted),
  WeightedEstimate = fmt(weighted$estimate), WeightedCI = ci(weighted),
  SubsetEstimate = fmt(subset_est$estimate), SubsetCI = ci(subset_est),
  RemainderN = remainder$n, RemainderEstimate = fmt(remainder$estimate),
  RemainderCI = ci(remainder),
  GoodSoph = fmt(good$sophisticated_pct), BadSoph = fmt(bad$sophisticated_pct),
  GoodNeutral = fmt(good$neutral_pct), BadNeutral = fmt(bad$neutral_pct),
  GoodUnsoph = fmt(good$unsophisticated_pct), BadUnsoph = fmt(bad$unsophisticated_pct),
  BinaryEstimate = fmt(threshold$estimate[3]), BinaryCI = ci(threshold[3, ]),
  BinaryHolmP = fmt(threshold$p_holm[3], 4),
  PermutationP = fmt(perm$p, 5), PermutationDraws = perm$draws,
  PermutationMCSE = fmt(perm$mc_se, 5),
  LeaveMin = fmt(influence$loo_min), LeaveMax = fmt(influence$loo_max),
  RankProbability = fmt(100 * ordinal$bad_higher_probability),
  RankP = fmt(ordinal$wilcoxon_p, 5),
  BadBeliefPct = fmt(belief$bad_pct[1]), GoodBeliefPct = fmt(100 - belief$bad_pct[1]),
  BadBeliefCI = ci(belief[1, ]),
  GoodRetention = fmt(selection$matched_pct[selection$arm == "Good people"]),
  BadRetention = fmt(selection$matched_pct[selection$arm == "Bad people"]),
  MaxBalance = fmt(max(abs(balance$standardized_difference)), 2),
  GoodESS = fmt(means$effective_n[means$sample == "Matched weighted" & means$arm == "Good people"]),
  BadESS = fmt(means$effective_n[means$sample == "Matched weighted" & means$arm == "Bad people"])
)
writeLines(paste0("\\newcommand{\\", names(values), "}{", values, "}"), "tabs/macros.tex")

latex_table <- function(rows, headers, align, filename) {
  lines <- c(
    paste0("\\begin{tabular}{", align, "}"), "\\toprule",
    paste0(paste(headers, collapse = " & "), " \\\\"), "\\midrule",
    apply(rows, 1, function(x) paste0(paste(x, collapse = " & "), " \\\\")),
    "\\bottomrule", "\\end{tabular}"
  )
  writeLines(lines, file.path("tabs", filename))
}
latex_table(
  cbind(est$specification, est$n, fmt(est$estimate), ci(est)),
  c("Analysis", "$n$", "Difference", "95\\% interval"), "lrrr", "estimates.tex"
)
full_flow <- flow[flow$sample == "full", ]
latex_table(
  cbind(
    ifelse(full_flow$order == 1, "Sophistication", "Own belief"),
    full_flow$arm, full_flow$assigned_n, full_flow$sophistication_n, full_flow$belief_n
  ),
  c("Pre-election question", "Tweet assignment", "Assigned", "Ratings", "Beliefs"),
  "llrrr", "flow.tex"
)
labels <- c(
  "Extremely", "Very or extremely", "At least somewhat", "At least neutral",
  "Above very unsophisticated", "Above extremely unsophisticated"
)
latex_table(
  cbind(labels, fmt(threshold$estimate), ci(threshold), fmt(threshold$p_holm, 4)),
  c("Sophistication threshold", "Difference", "95\\% interval", "Holm $p$"),
  "lrrr", "thresholds.tex"
)
interactions <- read_table("interactions")
latex_table(
  cbind(
    c(
      "Female minus male", "College minus no college",
      "Age 50+ minus under 50", "Republican minus other"
    ),
    fmt(interactions$estimate), ci(interactions), fmt(interactions$p_holm, 2)
  ),
  c("Difference in tweet contrast", "Estimate", "95\\% interval", "Holm $p$"),
  "lrrr", "interactions.tex"
)
readme <- readLines("docs/README.md.in", warn = FALSE)
for (key in names(values)) {
  readme <- gsub(paste0("@", key, "@"), values[[key]], readme, fixed = TRUE)
}
stopifnot(!any(grepl("@[A-Za-z]+@", readme)))
writeLines(readme, "README.md")
