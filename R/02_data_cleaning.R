# =============================================================================
# 02_data_cleaning.R
# Clean and merge student + school data for analysis
#
# Skills demonstrated: R proficiency, tidyverse (dplyr, tidyr), data wrangling
# =============================================================================

library(tidyverse)

# --- Load raw data ---
students <- read_csv("data/raw/pisa_students_2018.csv")
schools  <- read_csv("data/raw/pisa_schools_2018.csv")

# --- Clean student data ---
students_clean <- students %>%
  select(
    country, school_id, student_id,
    gender, mother_educ, father_educ,
    internet, computer, math, read, science,
    stu_wgt, wealth, escs, book
  ) %>%
  rename(
    reading_score  = read,
    math_score     = math,
    science_score  = science,
    student_weight = stu_wgt,
    ses_index      = escs
  ) %>%
  # Remove rows with missing reading scores
  filter(!is.na(reading_score)) %>%
  # Create derived variables
  mutate(
    has_internet   = if_else(internet == "yes", 1L, 0L),
    has_computer   = if_else(computer == "yes", 1L, 0L),
    gender_female  = if_else(gender == "female", 1L, 0L),
    ses_centered   = ses_index - mean(ses_index, na.rm = TRUE)
  )

# --- Clean school data ---
schools_clean <- schools %>%
  select(
    country, school_id,
    public_private, staff_shortage, stratio,
    sch_wgt, fund_gov, fund_fees, fund_donation,
    enrol_boys, enrol_girls, school_size
  ) %>%
  rename(
    school_type        = public_private,
    school_weight      = sch_wgt,
    student_teacher_ratio = stratio
  ) %>%
  mutate(
    is_public = if_else(school_type == "public", 1L, 0L)
  )

# --- Merge student and school data ---
merged <- students_clean %>%
  left_join(schools_clean, by = c("country", "school_id"))

# --- Create school-level aggregates ---
school_aggregates <- merged %>%
  group_by(country, school_id) %>%
  summarise(
    school_avg_reading = mean(reading_score, na.rm = TRUE),
    school_avg_ses     = mean(ses_index, na.rm = TRUE),
    school_n_students  = n(),
    school_pct_internet = mean(has_internet, na.rm = TRUE),
    .groups = "drop"
  )

# --- Final analysis dataset ---
analysis_data <- merged %>%
  left_join(school_aggregates, by = c("country", "school_id"))

# --- Summary ---
cat("Final dataset dimensions:", nrow(analysis_data), "x", ncol(analysis_data), "\n")
cat("Countries included:", n_distinct(analysis_data$country), "\n")

# Missingness summary
missing_pct <- analysis_data %>%
  summarise(across(everything(), ~ mean(is.na(.)) * 100)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "pct_missing") %>%
  filter(pct_missing > 0) %>%
  arrange(desc(pct_missing))

cat("\nVariables with missing data:\n")
print(missing_pct)

# --- Save ---
write_csv(analysis_data, "data/processed/analysis_data.csv")
cat("\nAnalysis dataset saved to data/processed/analysis_data.csv\n")
