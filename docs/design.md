# Research design and estimands

The available contrast asks whether a person who says politics attracts bad
people is rated more sophisticated than a person who says politics attracts
good people, holding the claim that the system rewards bad behavior constant.
The images also differ in "and" versus "but". The identified intervention, if
randomized, is this complete wording change; the design cannot separate moral
pessimism from the conjunction, perceived nuance, or agreement with the message.

## Reconstructed design

Two SPSS fields identify tweet assignment and pre/post question order. The labels
describe a plan in which respondents rate a tweet in one wave and report their
own belief in the other. In both available files, only the two pre-election
outcomes exist. Other post-election variables are present; a complete variable
name and label search found no additional sophistication or good/bad item.
All rating-arm respondents answer the rating, and all belief-arm respondents
answer the belief question. Thus the missing outcomes are structural routing,
not observed item attrition. The files contain respondents who completed this
survey; dropout before inclusion cannot be measured.

The codebook labels are `PolTweetBadBad`, `PolTweetGoodBad`, and `PolTweetGood`.
Only the first two have observations. Their wording matches `ps_bb_tweet.jpg`
and `ps_gb_tweet.jpg`. Four other images are retained, but their use is not
established. The filename/label correspondence supports the mapping; it is not
a verified survey-rendering log. The codebook supplies response labels and a
short outcome description, not the complete question stem.

## Claims and targets

| Question | Unit and population | Quantity | Interpretation and assumptions |
|---|---|---|---|
| Does the bad-people wording receive higher ratings? | One respondent; 711 in the full pre-election rating sample | Mean 0–100 rating under bad wording minus good wording | Sample assignment contrast; causal if assignment is random within rating routing, delivery follows assignment, and there is no interference |
| Does the comparison change with demographics? | Same 711 respondents | Fully interacted linear adjustment, covariates centered at sample means | Adjusted average contrast; same randomization assumptions and pre-treatment covariate timing |
| What about the selected survey sample? | 505 rating respondents retained in the supplied subset | Unweighted mean difference | Different sample target; selection may matter |
| What about survey weights? | Same 505, weighted by `teamweight` | Difference between normalized weighted arm means | Weighted target; national interpretation also requires valid matching/calibration and transport of effects |
| Is the pattern sensitive to equal response spacing? | Full rating sample | Six cumulative response-probability contrasts; rank comparison | Ordinal summaries; no equal-spacing assumption; each threshold changes the outcome |
| Do respondents themselves endorse the bad-people statement? | Separate 716-person pre-election belief sample | Fraction selecting bad people | Descriptive forced choice between two system-critical statements; not general prevalence of cynicism |
| Do cynics especially reward cynical speakers? | Would require both outcomes for the same people | Treatment-by-prior-belief interaction | Not identified by these files: joint observations = 0 |

The primary estimand is written as E[Y(1) − Y(0) | rating sample], with 1 denoting
the bad-people tweet. Respondents, not tweets or repeated survey records, are
the independent units under the assumed assignment mechanism. There are only
two fixed stimuli; inference does not generalize over a sampled population of
tweets or speakers.

## Analysis decisions

This is a retrospective analysis. No preregistration was found in the repository,
and primary/sensitivity labels describe the present analysis, not a historical
commitment. All seven response categories are retained. A neutral response is
50, not missing. No response is trimmed and no attention-check exclusion is
invented. Choosing the larger sample retains observations discarded by matching
and avoids conditioning the main comparison on inclusion in the selected
survey file. The selected and weighted estimates make that choice visible.

The primary interval uses the unequal-variance difference-of-means standard
error, sqrt(s1²/n1 + s0²/n0), with Welch–Satterthwaite degrees of freedom.
Arm intervals use SD/sqrt(n) and t critical values. Adjusted and weighted fits
use HC3 covariance and residual-df t intervals. Adjustment includes centered
age, female, college, White-category, and four party indicators, all interacted
with treatment. No covariate is selected because of its balance statistic.
Separate belief proportions use intercept-only regressions with HC3 t intervals;
the weighted version also treats the supplied weights as fixed.

A two-sided permutation check shuffles assignment within the rating sample,
holding its observed arm sizes fixed, using 19,999 draws and seed 20261004.
It tests a sharp no-effect null under complete random assignment, conditional
on arm totals, with p = (exceedances + 1)/(draws + 1). Because the assignment
program is absent, this is an assumption-dependent check, not verification of
the actual randomization distribution.

Six cumulative thresholds form one exploratory family, with Holm adjustment.
Four treatment interactions (gender, college, age 50+, and Republican identity)
form a separate family. Interactions compare effects directly; differing
subgroup significance is not evidence of heterogeneity. The primary scale
contrast is reported separately. The ordinal rank p-value is supplementary and
is not an additional confirmatory test. Weighting, subset, and rounded-scale
estimates are shown together rather than searched for a favorable result.

See [sandwich's HC covariance documentation](https://sandwich.r-forge.r-project.org/reference/vcovHC.html)
for the covariance API, and the tests for direct numerical verification.
