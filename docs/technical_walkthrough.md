# Technical Walkthrough: Educational Data Impact Project

This document provides a detailed explanation of the project's data flow, statistical logic, and technical implementation. Use this to prepare for technical interviews and a deeper understanding of your own portfolio piece.

---

## 1. Project Overview & Research Context

The goal of this project was to determine how **school-level resources** (like internet access, funding, and teacher-student ratios) predict **reading achievement** in students, using the **PISA 2018 (Reading focus)** dataset.

> **Why PISA 2018?** PISA rotates its focus. 2018 was specifically centered on "Reading Literacy," providing the most granular data for a reading-focused role like Newsela's.

---

## 2. Technical Stack & Data Flow

### Key Technical Decisions:
- **Tidyverse Fluency:** Using `dplyr` and `tidyr` to manage a dataset with 612K rows and 80+ countries. 
- **SQL Integration:** We loaded the data into a **SQLite database** (`data/education.db`) to demonstrate "basic experience with querying in SQL." This shows you can handle data at scale and use hybrid workflows (R + SQL).

### Script Breakdown:
- **`R/01_data_acquisition.R`**: Downloads the large subset of PISA 2018 data via the `learningtower` package. This mimics typical data engineering "Extraction" phases.
- **`R/02_data_cleaning.R`**: Joins student-level variables (like SES, gender, internet availability) with school-level attributes (like public/private status and staff shortages).
- **`R/03_sql_demo.R`**: Loads the cleaned dataset into a SQLite database and performs aggregations (simulating an environment where data is too large for memory alone).
- **`R/04_eda.R`**: Conducts Exploratory Data Analysis (EDA) and generates publication-ready visualizations found under `figures/`. 
- **`R/05_multilevel_models.R`**: The core statistical processing (Hierarchical Linear Modeling).

---

## 3. Deep Dive: Statistical Modeling (HLM)

Newsela specifically asks for experience with **Multilevel/Hierarchical modeling**. This is the "soul" of the project.

### Why HLM?
Standard regression (OLS) assumes all students are independent. But students in the same school share the same teachers, and schools in the same country share the same education policy. **HLM accounts for this "nesting"** and provides more accurate estimates of standard errors. Without HLM, we would underestimate standard errors for school-level attributes, leading to false-positive conclusions.

### The 3-Level Structure:
1.  **Level 1 (Student):** Gender, Socioeconomic Status (SES), Internet Access. Provides the base variance.
2.  **Level 2 (School):** School-average SES, Teacher-Student Ratio, Public vs. Private. Helps model how school environment affects the baseline reading capabilities.
3.  **Level 3 (Country):** Geography and Policy. This level essentially handles the "noise" introduced by differing national curricula and economic baselines.

### Key Metrics to Know:
- **ICC (Intraclass Correlation Coefficient):** Your null model showed an **ICC of ~0.50**. This means **50% of the variance** in reading scores is due to "between-school" or "between-country" differences. An ICC above 0.10 statistically justifies using HLM.
- **R-Squared (Marginal vs. Conditional):** 
    - **Marginal:** Variance explained by fixed effects (your predictors).
    - **Conditional:** Variance explained by the entire model, including random effects (school/country differences).
- **Cross-Level Interaction:** We tested `ses_centered * school_avg_ses`. This is the **Equity Finding**: the interaction reveals whether the school's overall environment narrows or widens the gap for individual students. (e.g., Does a low-SES student do better in a high-SES school than they would in a low-SES school?)

---

## 4. Understanding the Results

### Key Predictors (from `05_multilevel_models.R`):
- **School Average SES ($\beta \approx 58.3$):** The single strongest predictor. Attending a well-resourced school provides a significant "boost" even after accounting for a student's own background.
- **Gender ($\beta \approx 22.0$):** Being female is strongly associated with higher reading scores, a consistent finding in educational data mining.
- **Internet Access ($\beta \approx 14.8$):** Home internet access correlates with a 15-point increase in reading, highlighting the importance of digital equity.

---

## 5. Troubleshooting & Methodology Notes

### Messy Data & Missingness:
PISA data is notorious for missing variables (e.g., SES components). In this project, we used **complete-case analysis** after filtering for key variables, which is a common first-pass technique in learning analytics. For a more robust academic paper setting, Multiple Imputation (e.g., via the `mice` package) would be ideal.

### Standardization:
We **grand-mean centered** the Socioeconomic Status (SES) index. This makes the "Intercept" in your model represent the reading score of an "average" student, which makes the results much easier to interpret during an interview.
