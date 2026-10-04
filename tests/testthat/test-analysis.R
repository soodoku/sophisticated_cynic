testthat::test_that("coding preserves endpoints, neutral responses and structural missingness", {
  testthat::expect_equal(recode_sophistication(c(1, 4, 7, 98, 99, NA)), c(100, 50, 0, NA, NA, NA))
  testthat::expect_error(recode_sophistication(8))
  testthat::expect_error(recode_sophistication(factor(1:7)))
  testthat::expect_equal(diff(recode_sophistication(1:7)), rep(-100 / 6, 6))
})

testthat::test_that("difference and uncertainty reproduce an independent Welch implementation", {
  y <- c(1, 4, 8, 11, 0, 2, 3, 9, 10)
  z <- c(rep(1, 4), rep(0, 5))
  ours <- mean_difference(y, z)
  reference <- stats::t.test(y[z == 1], y[z == 0])
  testthat::expect_equal(ours$estimate, -unname(diff(reference$estimate)))
  testthat::expect_equal(c(ours$lower, ours$upper), as.numeric(reference$conf.int))
  testthat::expect_equal(ours$p, reference$p.value)
  fit <- stats::lm(y ~ z)
  testthat::expect_equal(ours$se, sqrt(sandwich::vcovHC(fit, type = "HC2")[2, 2]))
})

testthat::test_that("weighted HC3 agrees with a direct arm-wise variance calculation", {
  d <- data.frame(y = c(3, 7, 8, 0, 2, 5), bad = rep(0:1, each = 3), w = c(1, 2, 5, 3, 1, 2))
  fit <- stats::lm(y ~ bad, d, weights = w)
  arm <- lapply(split(d, d$bad), function(a) {
    w <- a$w / sum(a$w)
    m <- sum(w * a$y)
    c(mean = m, variance = sum((w * (a$y - m) / (1 - w))^2))
  })
  got <- model_result(fit)
  testthat::expect_equal(got$estimate, unname(arm[[2]][1] - arm[[1]][1]))
  testthat::expect_equal(got$se, unname(sqrt(arm[[1]][2] + arm[[2]][2])))
})

testthat::test_that("permutation is repeatable and cannot report zero", {
  y <- 1:20
  z <- rep(0:1, each = 10)
  first <- permutation_test(y, z, draws = 99, seed = 42)
  testthat::expect_identical(first, permutation_test(y, z, draws = 99, seed = 42))
  testthat::expect_gte(first$p, 1 / 100)
  testthat::expect_equal(first$p, (first$exceed + 1) / 100)
})

testthat::test_that("the actual mean estimator recovers a planted effect with nominal coverage", {
  set.seed(3107)
  results <- replicate(400, {
    z <- rep(0:1, each = 100)
    y <- 30 + 8 * z + stats::rnorm(200, sd = 10 + 5 * z)
    r <- mean_difference(y, z)
    c(estimate = r$estimate, covered = r$lower <= 8 && r$upper >= 8)
  })
  testthat::expect_lt(abs(mean(results["estimate", ]) - 8), 0.4)
  testthat::expect_gt(mean(results["covered", ]), 0.91)
  testthat::expect_lt(mean(results["covered", ]), 0.99)
})

testthat::test_that("centered interaction adjustment recovers a known heterogeneous model", {
  set.seed(59)
  n <- 1000
  d <- data.frame(
    bad = rep(0:1, each = n / 2), age = stats::runif(n, 18, 80),
    female = stats::rbinom(n, 1, 0.5), college = stats::rbinom(n, 1, 0.4),
    white = stats::rbinom(n, 1, 0.7), party = factor(sample(1:5, n, TRUE))
  )
  d$sophistication <- 10 + 0.1 * d$age + d$bad * (4 + 0.2 * d$age)
  fit <- fit_adjusted(d)
  testthat::expect_equal(unname(stats::coef(fit)["bad"]), mean(4 + 0.2 * d$age))
})
