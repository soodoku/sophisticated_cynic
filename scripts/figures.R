library(ggplot2)
source("R/style.R")
dir.create("figs", showWarnings = FALSE)
means <- read.csv("tabs/arm_means.csv")
means <- means[means$sample == "Full sample", ]
means$arm <- factor(means$arm, levels = c("Bad people", "Good people"))
means$label <- sprintf("%.1f (n = %s)", means$mean, means$n)
p <- ggplot(means, aes(mean, arm, color = arm)) +
  geom_vline(xintercept = 50, linetype = "dashed", color = "grey60") +
  geom_errorbar(aes(xmin = lower, xmax = upper), orientation = "y", width = 0.14) +
  geom_point(size = 3.2) +
  geom_text(aes(label = label), nudge_y = 0.22, color = "#222222", size = 4) +
  scale_color_manual(values = arm_colors) +
  scale_x_continuous(limits = c(0, 100), breaks = seq(0, 100, 25)) +
  labs(
    title = "Greater cynicism receives lower sophistication ratings",
    subtitle = "Both tweets say the system rewards bad behavior",
    x = "Mean perceived sophistication (0-100)",
    caption = paste(
      "Full pre-election rating sample. Points: arm means; bars: 95% t intervals.",
      "50 is the neutral response, not a no-tweet control.",
      sep = "\n"
    )
  ) +
  figure_theme()
save_figure(p, "sophistication", height = 3.9)

est <- read.csv("tabs/estimates.csv")
est$specification <- factor(est$specification, levels = rev(est$specification))
p <- ggplot(est, aes(estimate, specification)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey60") +
  geom_errorbar(aes(xmin = lower, xmax = upper), orientation = "y", width = 0.15) +
  geom_point(size = 2.7, color = "#007A87") +
  labs(
    title = "Estimates across samples and specifications",
    subtitle = "Bad-people tweet minus good-people tweet",
    x = "Difference in sophistication (0-100 scale points)",
    caption = paste(
      "Bars: 95% intervals (Welch; HC3 t for adjusted and weighted fits).",
      "Subsets and weighting change the target; these are not independent replications.",
      sep = "\n"
    )
  ) +
  figure_theme()
save_figure(p, "estimates", height = 4.5)

dist <- read.csv("tabs/distribution.csv")
response_labels <- c(
  "Extremely\nsophisticated", "Very\nsophisticated", "Somewhat\nsophisticated",
  "Neither", "Somewhat\nunsophisticated", "Very\nunsophisticated", "Extremely\nunsophisticated"
)
response_labels <- gsub("\n", " ", response_labels, fixed = TRUE)
dist$response <- factor(dist$score_code, levels = 7:1, labels = rev(response_labels))
dist$arm <- factor(dist$arm, levels = c("Good people", "Bad people"))
p <- ggplot(dist, aes(pct, response, fill = arm)) +
  geom_col(width = 0.7) +
  facet_wrap(~arm, ncol = 2) +
  scale_fill_manual(values = arm_colors) +
  scale_x_continuous(limits = c(0, 50), breaks = c(0, 25, 50)) +
  labs(
    title = "Ratings shift away from sophisticated",
    x = "Percent within tweet arm", y = NULL,
    caption = paste0(
      sprintf(
        "Full rating sample: good people n = %s; bad people n = %s.\n",
        means$n[means$arm == "Good people"], means$n[means$arm == "Bad people"]
      ),
      "All seven response categories retained."
    )
  ) +
  figure_theme()
save_figure(p, "distribution", height = 4.5)
