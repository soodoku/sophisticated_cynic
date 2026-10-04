testthat::test_that("sources reconcile and routing distinguishes not asked from nonresponse", {
  previous <- setwd(root)
  on.exit(setwd(previous))
  raw <- read_sources()
  d <- build_data(raw$full, raw$matched$caseid)
  testthat::expect_equal(nrow(d), 1427)
  testthat::expect_equal(sum(d$matched), 1000)
  testthat::expect_equal(sum(!is.na(d$sophistication)), 711)
  testthat::expect_equal(sum(!is.na(d$bad_belief)), 716)
  testthat::expect_equal(sum(!is.na(d$sophistication) & !is.na(d$bad_belief)), 0)
  testthat::expect_equal(sum(d$asked_sophistication & is.na(d$sophistication)), 0)
  testthat::expect_true(all(d$weight[d$matched] > 0))
  first_rating <- which(raw$full$AGTPolCynic_AGTGoodBad_order == 1)[1]
  raw$full$AGTPolCynic_pre[first_rating] <- 99
  testthat::expect_error(build_data(raw$full, raw$matched$caseid))
})

testthat::test_that("observed data reproduce means, denominators and uncertainty", {
  d <- read.csv(file.path(root, "data/derived/respondents.csv"))
  a <- d[d$asked_sophistication, ]
  reference <- stats::t.test(sophistication ~ bad, a)
  estimates <- read.csv(file.path(root, "tabs/estimates.csv"))
  main <- estimates[estimates$specification == "Full sample", ]
  testthat::expect_equal(main$estimate, unname(diff(reference$estimate)))
  testthat::expect_equal(main$se, 1.642527, tolerance = 1e-6)
  testthat::expect_equal(main$estimate, -6.190193, tolerance = 1e-6)
  dist <- read.csv(file.path(root, "tabs/distribution.csv"))
  testthat::expect_equal(sum(dist$n), 711)
  testthat::expect_equal(as.numeric(tapply(dist$pct, dist$arm, sum)), c(100, 100))
  means <- read.csv(file.path(root, "tabs/arm_means.csv"))
  testthat::expect_equal(means$mean[1:2], c(53.6486486486486, 47.4584555229717))
  for (z in 0:1) {
    y <- a$sophistication[a$bad == z]
    testthat::expect_equal(means$se[z + 1], stats::sd(y) / sqrt(length(y)))
  }
})

testthat::test_that("influence diagnostics equal actual deletions", {
  d <- read.csv(file.path(root, "data/derived/respondents.csv"))
  a <- d[d$asked_sophistication, ]
  fit <- stats::lm(sophistication ~ bad, a)
  deleted <- stats::coef(fit)["bad"] - stats::dfbeta(fit)[, "bad"]
  for (i in c(1, which.min(deleted), which.max(deleted))) {
    reference <- stats::coef(stats::lm(sophistication ~ bad, a[-i, ]))["bad"]
    testthat::expect_equal(unname(deleted[i]), unname(reference))
  }
})
