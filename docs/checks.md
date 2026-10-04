# Analysis checks

`make check` regenerates the analysis and report before running lint and tests.
The statistical tests check coding, sample reconciliation, known-parameter
recovery, and independent formulas. They do not read narrative claims to decide
whether the analysis is correct.

| Area | Check and evidence | Scope |
|---|---|---|
| Denominators | `sample_flow.csv`, `distribution.csv`, and tests reconcile assigned respondents, observed ratings, and within-arm percentages | One rating per person; no denominator borrowed from the other question route |
| Missingness | Raw SPSS user-missing codes retained; routing asserted against actual responses | Structural not-asked values stay missing; no item nonresponse among routed respondents; pre-inclusion dropout unobserved |
| Row conservation | Unique IDs asserted; selected-file IDs matched one to one; shared assignment/outcome/weight fields compared exactly | Files are overlapping samples, never stacked |
| Provenance | SHA-256 source manifest; all analytical prose numbers use generated macros; README generated from a template | Source data remain unchanged; clean rebuild regenerates all estimates |
| Internal consistency | Mean, SE, outcome distribution, and sample size checked independently against raw-derived observations | README, report, figures, and tables share the same estimates |
| Distributions | Seven-category distributions, cumulative thresholds, and arm means | Midpoint is a substantive response; no trimming, winsorization, or hidden zero imputation |
| Construction | Endpoint, neutral, equal-spacing, unknown-code, and missing-code tests | Perceived sophistication is not actual knowledge; single item, so internal-consistency scale reliability is inapplicable |
| Estimand | `design.md` states the target for each specification | Full sample, selected sample, and weighted target remain distinct |
| Inference | Welch result independently checked with `t.test`; HC2 equivalence checked; weighted HC3 directly derived from residuals | Respondent independence and random assignment are assumptions; vendor weight estimation is not propagated |
| Randomization | Split fields, route counts, balance table, conditional permutation calculation | Original assignment program and delivery logs unavailable; balance cannot validate randomization |
| Adjustment | Complete demographics, centered covariates, fully interacted treatment; planted heterogeneous model recovered | Timing treated as pre-treatment, pending questionnaire verification |
| Influence | Exact case-deletion effects, leverage, DFBETAs, matrix rank and condition number for main, adjusted, and weighted models | One-respondent sensitivity is observable; variation across untested stimuli is not |
| Multiplicity | All six cumulative thresholds and four direct demographic interaction tests reported; Holm correction within each family | Exploratory families; no claim of preregistration or broad confirmatory error control |
| Scale sensitivity | Rounded scoring, thresholds, rank comparison, and full distribution | Rank comparison is supplementary; medians alone hide distribution differences |
| Selection and weighting | Matched inclusion by arm, remainder estimate, selected estimates with/without weights, arm effective sample sizes | Similar inclusion rates do not establish ignorable selection; national generalization needs additional assumptions |
| Simulation | Actual mean-difference routine evaluated on repeated data with a known effect and unequal variances | Checks implementation and interval coverage under the assumed model, not validity of field assignment |
| Mechanisms | Separate belief-sample proportions and explicit joint-outcome count | Individual agreement/cynicism moderation cannot be estimated; no post-treatment belief adjustment |
| Precision | Effect sizes and intervals in scale points and response probabilities; interaction intervals shown | Imprecise subgroup tests do not imply homogeneous effects; no post-hoc observed-power claim |
| Other designs | No panel treatment path, time-series estimator, IV, discontinuity, or difference-in-differences | Those identification checks are inapplicable |

The main claim answers whether the two statements receive different ratings. A
randomized comparison is a reasonable design for that question, conditional on
the assignment and delivery assumptions described in `design.md`. The formulas
are verified against independent implementations and simulated data. The
interpretation remains specific to these statements and this measured perception;
the analysis does not identify agreement as the mechanism or establish a general
penalty for cynicism.
