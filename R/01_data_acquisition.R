# =============================================================================
# 01_data_acquisition.R
# Download and prepare PISA reading data using the learningtower R package
#
# Skills demonstrated: R proficiency, tidyverse (dplyr, readr)
# =============================================================================

library(tidyverse)
library(learningtower)

# --- Load PISA student data (2018 is the most recent reading-focused cycle) ---
# learningtower provides the full PISA dataset via load_student()
student_data <- load_student("2018")

# --- Load PISA school data (built-in dataset) ---
data(school)
school_data <- school %>% filter(year == 2018)

# --- Quick inspection ---
glimpse(student_data)
glimpse(school_data)

cat("Student records:", nrow(student_data), "\n")
cat("School records:", nrow(school_data), "\n")
cat("Countries:", n_distinct(student_data$country), "\n")

# --- Save raw data locally ---
write_csv(student_data, "data/raw/pisa_students_2018.csv")
write_csv(school_data, "data/raw/pisa_schools_2018.csv")

cat("Raw data saved to data/raw/\n")
