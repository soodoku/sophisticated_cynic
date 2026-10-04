source_paths <- function() {
  c(
    full = "data/cces/UCM_CES2020_Unweighted_Data.sav",
    matched = "data/cces/UCM_CES2020_Weighted_Data.sav"
  )
}

recode_sophistication <- function(x) {
  stopifnot(is.numeric(x))
  x <- as.numeric(x)
  stopifnot(all(is.na(x) | x %in% c(1:7, 98, 99)))
  ifelse(x %in% 1:7, (7 - x) * 100 / 6, NA_real_)
}

read_sources <- function() {
  sources <- lapply(source_paths(), haven::read_sav, user_na = TRUE)
  for (d in sources) {
    stopifnot(!anyNA(d$caseid), !anyDuplicated(d$caseid))
  }
  u <- sources$full
  w <- sources$matched
  index <- match(w$caseid, u$caseid)
  stopifnot(!anyNA(index), nrow(u) == 1427L, nrow(w) == 1000L)
  same <- c(
    "AGTPolCynic_split", "AGTPolCynic_AGTGoodBad_order",
    "AGTPolCynic_pre", "AGTGoodBad_pre", "teamweight",
    "birthyr", "gender", "educ", "race", "pid3"
  )
  for (v in same) {
    stopifnot(identical(as.numeric(w[[v]]), as.numeric(u[[v]][index])))
  }
  stopifnot(setequal(u$caseid[!is.na(u$teamweight)], w$caseid))
  sources
}

build_data <- function(raw, matched_ids) {
  score <- as.numeric(raw$AGTPolCynic_pre)
  belief <- as.numeric(raw$AGTGoodBad_pre)
  arm <- as.numeric(raw$AGTPolCynic_split)
  order <- as.numeric(raw$AGTPolCynic_AGTGoodBad_order)
  stopifnot(
    all(arm %in% 1:2), all(order %in% 1:2),
    all((order == 1) == (score %in% 1:7)),
    all((order == 2) == (score == 99)),
    all((order == 2) == (belief %in% 1:2)),
    all((order == 1) == (belief == 9))
  )
  stopifnot(
    all(as.numeric(raw$birthyr) %in% 1900:2002),
    all(as.numeric(raw$gender) %in% 1:2),
    all(as.numeric(raw$educ) %in% 1:6),
    all(as.numeric(raw$race) %in% 1:8),
    all(as.numeric(raw$pid3) %in% 1:5)
  )
  data.frame(
    caseid = as.numeric(raw$caseid),
    bad = as.integer(arm == 1),
    arm = ifelse(arm == 1, "Bad people", "Good people"),
    order = order,
    asked_sophistication = order == 1,
    score_code = score,
    sophistication = recode_sophistication(score),
    belief_code = belief,
    bad_belief = ifelse(belief %in% 1:2, as.integer(belief == 2), NA_integer_),
    matched = raw$caseid %in% matched_ids,
    weight = as.numeric(raw$teamweight),
    age = 2020 - as.numeric(raw$birthyr),
    female = as.integer(as.numeric(raw$gender) == 2),
    college = as.integer(as.numeric(raw$educ) >= 5),
    white = as.integer(as.numeric(raw$race) == 1),
    party = factor(as.numeric(raw$pid3), levels = 1:5),
    start_date = as.Date(raw$starttime)
  )
}

write_csv <- function(x, name) {
  utils::write.csv(x, file.path("tabs", paste0(name, ".csv")), row.names = FALSE, na = "")
}

data_dictionary <- function(raw) {
  variables <- c(
    "caseid", "teamweight", "AGTPolCynic_split", "AGTPolCynic_AGTGoodBad_order",
    "AGTPolCynic_pre", "AGTGoodBad_pre", "birthyr", "gender", "educ", "race", "pid3"
  )
  do.call(rbind, lapply(variables, function(v) {
    labels <- attr(raw[[v]], "labels")
    data.frame(
      variable = v, description = attr(raw[[v]], "label"),
      code = if (length(labels)) as.numeric(labels) else NA_real_,
      value_label = if (length(labels)) names(labels) else "Numeric value"
    )
  }))
}
