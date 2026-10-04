mean_difference <- function(y, z) {
  stopifnot(length(y) == length(z), all(z %in% 0:1), !anyNA(y))
  a <- y[z == 1]
  b <- y[z == 0]
  stopifnot(length(a) > 1, length(b) > 1)
  va <- stats::var(a) / length(a)
  vb <- stats::var(b) / length(b)
  se <- sqrt(va + vb)
  df <- (va + vb)^2 / (va^2 / (length(a) - 1) + vb^2 / (length(b) - 1))
  estimate <- mean(a) - mean(b)
  critical <- stats::qt(0.975, df)
  data.frame(
    n = length(y), estimate = estimate, se = se, df = df,
    lower = estimate - critical * se, upper = estimate + critical * se,
    p = 2 * stats::pt(-abs(estimate / se), df), method = "Welch"
  )
}

model_result <- function(fit, term = "bad") {
  covariance <- sandwich::vcovHC(fit, type = "HC3")
  estimate <- stats::coef(fit)[term]
  se <- sqrt(covariance[term, term])
  df <- stats::df.residual(fit)
  critical <- stats::qt(0.975, df)
  data.frame(
    n = stats::nobs(fit), estimate = unname(estimate), se = se, df = df,
    lower = unname(estimate) - critical * se,
    upper = unname(estimate) + critical * se,
    p = 2 * stats::pt(-abs(estimate / se), df), method = "HC3 t"
  )
}

fit_adjusted <- function(d) {
  for (v in c("age", "female", "college", "white")) d[[v]] <- d[[v]] - mean(d[[v]])
  party <- stats::model.matrix(~party, d)[, -1, drop = FALSE]
  party <- sweep(party, 2, colMeans(party), "-")
  d <- cbind(d, party)
  covariates <- c("age", "female", "college", "white", colnames(party))
  formula <- stats::as.formula(paste(
    "sophistication ~ bad * (", paste(covariates, collapse = "+"), ")"
  ))
  stats::lm(formula, d, na.action = stats::na.fail)
}

arm_summary <- function(d, weighted = FALSE) {
  do.call(rbind, lapply(0:1, function(z) {
    a <- d[d$bad == z, ]
    w <- if (weighted) a$weight else rep(1, nrow(a))
    fit <- stats::lm(sophistication ~ 1, a, weights = w)
    se <- if (weighted) {
      sqrt(sandwich::vcovHC(fit, type = "HC3")[1, 1])
    } else {
      stats::sd(a$sophistication) / sqrt(nrow(a))
    }
    avg <- stats::weighted.mean(a$sophistication, w)
    critical <- stats::qt(0.975, nrow(a) - 1)
    data.frame(
      arm = a$arm[1], n = nrow(a), mean = avg, se = se,
      lower = avg - critical * se, upper = avg + critical * se,
      effective_n = sum(w)^2 / sum(w^2),
      sophisticated_pct = 100 * stats::weighted.mean(a$score_code <= 3, w),
      neutral_pct = 100 * stats::weighted.mean(a$score_code == 4, w),
      unsophisticated_pct = 100 * stats::weighted.mean(a$score_code >= 5, w)
    )
  }))
}

permutation_test <- function(y, z, draws = 19999L, seed = 20261004L) {
  set.seed(seed)
  observed <- abs(mean(y[z == 1]) - mean(y[z == 0]))
  n1 <- sum(z == 1)
  n0 <- sum(z == 0)
  total <- sum(y)
  simulated <- replicate(draws, {
    s1 <- sum(y[sample.int(length(y), n1)])
    abs(s1 / n1 - (total - s1) / n0)
  })
  exceed <- sum(simulated >= observed - 1e-10)
  p <- (exceed + 1) / (draws + 1)
  data.frame(draws = draws, seed = seed, exceed = exceed, p = p, mc_se = sqrt(p * (1 - p) / draws))
}

influence_summary <- function(d, fit) {
  loo <- unname(stats::coef(fit)["bad"]) - stats::dfbeta(fit)[, "bad"]
  x <- stats::model.matrix(fit)
  data.frame(
    n = nrow(d), columns = ncol(x), rank = qr(x)$rank,
    condition_number = kappa(x), max_leverage = max(stats::hatvalues(fit)),
    loo_min = min(loo), loo_max = max(loo),
    max_abs_dfbeta = max(abs(stats::dfbetas(fit)[, "bad"]))
  )
}

balance_summary <- function(d) {
  vars <- c("age", "female", "college", "white")
  party <- stats::model.matrix(~ party - 1, d)
  d <- cbind(d, party)
  vars <- c(vars, colnames(party))
  do.call(rbind, lapply(vars, function(v) {
    x <- d[[v]]
    a <- x[d$bad == 1]
    b <- x[d$bad == 0]
    data.frame(
      variable = v, n = length(x), bad_mean = mean(a), good_mean = mean(b),
      standardized_difference = (mean(a) - mean(b)) / sqrt((stats::var(a) + stats::var(b)) / 2)
    )
  }))
}

threshold_summary <- function(d) {
  out <- do.call(rbind, lapply(1:6, function(k) {
    y <- 100 * as.integer(d$score_code <= k)
    cbind(threshold_code = k, mean_difference(y, d$bad))
  }))
  out$p_holm <- stats::p.adjust(out$p, method = "holm")
  out
}

subgroup_summary <- function(d) {
  d$older <- as.integer(d$age >= 50)
  d$republican <- as.integer(d$party == "2")
  out <- do.call(rbind, lapply(c("female", "college", "older", "republican"), function(v) {
    fit <- stats::lm(stats::as.formula(paste("sophistication ~ bad *", v)), d)
    interaction <- model_result(fit, paste0("bad:", v))
    cbind(variable = v, interaction)
  }))
  out$p_holm <- stats::p.adjust(out$p, method = "holm")
  out
}
