-- =============================================================================
-- queries.sql
-- SQL queries used in the analysis (also executed via R in 03_sql_demo.R)
-- =============================================================================

-- Average reading score by country (top 10)
SELECT country,
       ROUND(AVG(reading_score), 1) AS avg_reading,
       COUNT(*) AS n_students
FROM students
GROUP BY country
ORDER BY avg_reading DESC
LIMIT 10;

-- Gender gap in reading by country
SELECT country,
       ROUND(AVG(CASE WHEN gender_female = 1 THEN reading_score END), 1) AS female_avg,
       ROUND(AVG(CASE WHEN gender_female = 0 THEN reading_score END), 1) AS male_avg,
       ROUND(AVG(CASE WHEN gender_female = 1 THEN reading_score END) -
             AVG(CASE WHEN gender_female = 0 THEN reading_score END), 1) AS gender_gap
FROM students
GROUP BY country
HAVING COUNT(*) > 20
ORDER BY gender_gap DESC;

-- Public vs private school reading scores
SELECT school_type,
       ROUND(AVG(reading_score), 1) AS avg_reading,
       ROUND(AVG(ses_index), 2) AS avg_ses,
       COUNT(*) AS n
FROM students
WHERE school_type IS NOT NULL
GROUP BY school_type;

-- Students with internet access vs without
SELECT has_internet,
       ROUND(AVG(reading_score), 1) AS avg_reading,
       ROUND(AVG(ses_index), 2) AS avg_ses,
       COUNT(*) AS n
FROM students
GROUP BY has_internet;
