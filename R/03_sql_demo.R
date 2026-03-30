# =============================================================================
# 03_sql_demo.R
# Load data into SQLite and run queries to extract analysis subsets
#
# Skills demonstrated: Basic SQL experience, R + database integration
# =============================================================================

library(tidyverse)
library(DBI)
library(RSQLite)

# --- Load cleaned data ---
analysis_data <- read_csv("data/processed/analysis_data.csv")

# --- Create SQLite database ---
con <- dbConnect(SQLite(), "data/education.db")

# Write tables to the database
dbWriteTable(con, "students", analysis_data, overwrite = TRUE)

cat("Database created with", dbListTables(con), "table(s)\n")

# --- Run SQL queries ---

# Query 1: Average reading score by country (top 10)
query1 <- "
  SELECT country,
         ROUND(AVG(reading_score), 1) AS avg_reading,
         COUNT(*) AS n_students
  FROM students
  GROUP BY country
  ORDER BY avg_reading DESC
  LIMIT 10
"
top_countries <- dbGetQuery(con, query1)
cat("\nTop 10 countries by reading score:\n")
print(top_countries)

# Query 2: Gender gap in reading by country
query2 <- "
  SELECT country,
         ROUND(AVG(CASE WHEN gender_female = 1 THEN reading_score END), 1) AS female_avg,
         ROUND(AVG(CASE WHEN gender_female = 0 THEN reading_score END), 1) AS male_avg,
         ROUND(AVG(CASE WHEN gender_female = 1 THEN reading_score END) -
               AVG(CASE WHEN gender_female = 0 THEN reading_score END), 1) AS gender_gap
  FROM students
  GROUP BY country
  HAVING COUNT(*) > 20
  ORDER BY gender_gap DESC
"
gender_gaps <- dbGetQuery(con, query2)
cat("\nGender gap in reading (top 10):\n")
print(head(gender_gaps, 10))

# Query 3: Public vs private school reading scores
query3 <- "
  SELECT school_type,
         ROUND(AVG(reading_score), 1) AS avg_reading,
         ROUND(AVG(ses_index), 2) AS avg_ses,
         COUNT(*) AS n
  FROM students
  WHERE school_type IS NOT NULL
  GROUP BY school_type
"
school_type_results <- dbGetQuery(con, query3)
cat("\nPublic vs Private schools:\n")
print(school_type_results)

# Query 4: Students with internet vs without
query4 <- "
  SELECT has_internet,
         ROUND(AVG(reading_score), 1) AS avg_reading,
         ROUND(AVG(ses_index), 2) AS avg_ses,
         COUNT(*) AS n
  FROM students
  GROUP BY has_internet
"
internet_results <- dbGetQuery(con, query4)
cat("\nInternet access and reading:\n")
print(internet_results)

# --- Also save query file for reference ---
# (SQL queries also stored in sql/queries.sql)

# --- Clean up ---
dbDisconnect(con)
cat("\nDatabase queries complete. Results above.\n")
