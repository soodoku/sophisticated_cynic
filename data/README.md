# Data

The source files in `cces/` are preserved byte for byte. The codebooks identify
the 2020 CES UCM module. No separate questionnaire, randomization code,
preregistration, or module-specific weighting report is included.

| File | Rows | Columns | Pre-election field period |
|---|---:|---:|---|
| `UCM_CES2020_Unweighted_Data.sav` | 1,427 | 870 | September 30–November 2, 2020 |
| `UCM_CES2020_Weighted_Data.sav` | 1,000 | 878 | October 3–November 2, 2020 |

The weighted file is a subset, not another wave or an independent sample. All
1,000 `caseid` values appear in the larger file, and the treatment, order,
outcome, and `teamweight` fields agree exactly for shared cases. In the larger
file, the remaining 427 respondents have no team weight. The pipeline never
stacks these files. It calls the subset "matched" because the companion codebook
calls the larger file "unmatched"; its exact selection algorithm is not supplied.

The standard CES process uses matching and post-stratification; the
[official CES FAQ](https://tischcollege.tufts.edu/research-faculty/research-centers/cooperative-election-study/cooperative-election-study-faqs)
provides general context. It does not document the selection or calibration
targets for this particular team file. `teamweight` is the supplied Team Weight;
`team_vvweight` is not used for these pre-election outcomes. Weighted uncertainty
treats the weights as fixed and does not recreate the vendor's sample construction.

## Coding

`haven::read_sav(user_na = TRUE)` retains the distinction between SPSS user-missing
codes. The [haven documentation](https://haven.tidyverse.org/reference/read_spss.html)
explains that the default instead converts them to `NA`.

| Source | Meaning | Analysis |
|---|---|---|
| `AGTPolCynic_split` | 1 = BadBad; 2 = GoodBad; 3 = Good (unused) | `bad = 1` for code 1; reference code 2 |
| `AGTPolCynic_AGTGoodBad_order` | 1 = rating in pre; 2 = belief in pre | Defines the question-specific sample |
| `AGTPolCynic_pre` | 1 extremely sophisticated through 7 extremely unsophisticated | `100 * (7 - code) / 6` |
| `AGTPolCynic_pre` | 98 skipped; 99 not asked | Missing outcome; not converted to zero |
| `AGTGoodBad_pre` | 1 good people; 2 bad people; both say system rewards bad behavior | Binary bad-people belief; separate sample |
| `AGTGoodBad_pre` | 8 skipped; 9 not asked | Missing belief |
| `birthyr` | Birth year | Approximate age = 2020 − birth year |
| `gender` | Male/female categories in this survey | Female indicator |
| `educ` | Six education categories | Four-year degree or postgraduate = college |
| `race` | Eight survey categories | White category indicator; not a Hispanic-origin recode |
| `pid3` | Democrat, Republican, Independent, Other, Not sure | Five-category factor; uncertainty retained |

The main rating sample has no missing values in these adjustment covariates.
They are common-content or demographic fields treated as pre-treatment; the
full administration sequence is unavailable. Trust in government, need for
cognition, and other module items are not used as controls because their timing
relative to the tweet is not established.

`tabs/dictionary.csv` records original labels and codes. `tabs/source_manifest.csv`
records file sizes and SHA-256 hashes. `tabs/inventory.csv` and
`tabs/sample_flow.csv` record dates, denominators, routing, and observed outcomes.
`data/derived/respondents.csv` is a generated analysis extract, ignored by Git;
published outputs contain aggregates only.
