# How School Resources Shape Student Reading Achievement

A multilevel analysis of PISA 2018 international reading data, investigating how school-level factors predict student reading outcomes across countries.

## Skills Demonstrated

This project was designed to demonstrate specific research and technical skills. The table below maps each skill to the files and sections where it is applied.

| Skill | Where It's Demonstrated |
|---|---|
| **R for statistical analysis (tidyverse)** | All scripts in `R/` — every file uses `dplyr`, `tidyr`, `ggplot2`, `readr` for data manipulation, analysis, and visualization |
| **Fundamental statistics** | `R/04_eda.R` — descriptive statistics, correlations, distributions; `R/05_multilevel_models.R` — effect sizes, model comparison (AIC/BIC), R² |
| **SQL querying** | `R/03_sql_demo.R` — creates a SQLite database and runs analytical queries; `sql/queries.sql` — standalone SQL file with all queries |
| **Multilevel / hierarchical modeling** | `R/05_multilevel_models.R` — 4 progressively complex HLMs (null → student → school → cross-level interaction) using `lme4`, ICC computation, random effects |
| **Data visualization for varying audiences** | `R/04_eda.R` + `R/05_multilevel_models.R` — technical plots (coefficient plots, correlation matrices, random effects); `reports/executive_summary.Rmd` — simplified, annotated charts for non-technical readers |
| **Rmarkdown / markdown** | `reports/technical_report.Rmd` — full research report with embedded R code; `reports/executive_summary.Rmd` — non-technical summary; this `README.md` |
| **Educational research** | Entire project — uses PISA international assessment data to study reading literacy, SES–achievement gaps, and school resource effects |
| **Learning analytics / educational data mining** | `R/02_data_cleaning.R` — feature engineering from messy educational data; `R/05_multilevel_models.R` — partitioning variance across student/school/country levels |

## Project Structure

```
├── R/
│   ├── 01_data_acquisition.R      # Download PISA data via learningtower
│   ├── 02_data_cleaning.R         # Clean, merge, and engineer features
│   ├── 03_sql_demo.R              # SQL queries on education data
│   ├── 04_eda.R                   # Exploratory analysis and visualizations
│   └── 05_multilevel_models.R     # Hierarchical models (lme4)
├── sql/
│   └── queries.sql                # Standalone SQL queries
├── reports/
│   ├── technical_report.Rmd       # Full research report (Rmarkdown)
│   └── executive_summary.Rmd      # Non-technical summary for general audiences
├── data/                          # Raw and processed datasets (gitignored)
├── figures/                       # Generated plots
└── README.md
```

## Research Questions

1. **How much of the variation in reading scores is between schools and countries vs. within?** (ICC from null multilevel model)
2. **Which student-level factors predict reading achievement?** (Gender, SES, internet access)
3. **Do school-level characteristics matter beyond student factors?** (School type, staffing, average SES)
4. **Does school context moderate the SES–achievement gap?** (Cross-level interaction: individual SES × school SES)

## Data

- **Source**: PISA 2018 via the [`learningtower`](https://kevinwang09.github.io/learningtower/) R package
- **Scope**: Thousands of 15-year-old students across 80+ countries
- **Outcome**: PISA reading score
- **Predictors**: Student SES, gender, internet access, school type, staff shortage, school-average SES

## How to Run

```bash
# 1. Install R packages (one-time)
Rscript -e "install.packages(c('tidyverse', 'learningtower', 'RSQLite', 'DBI', 'lme4', 'lmerTest', 'performance', 'broom.mixed', 'rmarkdown'))"

# 2. Run scripts in order
Rscript R/01_data_acquisition.R
Rscript R/02_data_cleaning.R
Rscript R/03_sql_demo.R
Rscript R/04_eda.R
Rscript R/05_multilevel_models.R

# 3. Render reports
Rscript -e "rmarkdown::render('reports/technical_report.Rmd')"
Rscript -e "rmarkdown::render('reports/executive_summary.Rmd')"
```

## Tools & Packages

- **R** (4.4+)
- **tidyverse** — `dplyr`, `tidyr`, `ggplot2`, `readr`
- **lme4 / lmerTest** — multilevel modeling
- **RSQLite / DBI** — SQL database interaction
- **performance / broom.mixed** — model diagnostics and tidy output
- **rmarkdown** — reproducible reports