# =============================================================================
# 05_multilevel_models.R
# Hierarchical / multilevel modeling: students nested in schools nested in countries
#
# Skills demonstrated: Multilevel/hierarchical modeling, statistics, R
# =============================================================================

library(tidyverse)
library(lme4)
library(lmerTest)
library(performance)
library(broom.mixed)

# --- Load data ---
df <- read_csv("data/processed/analysis_data.csv")

# Drop rows with missing key variables for modeling
model_df <- df %>%
  select(reading_score, gender_female, ses_centered, ses_index,
         has_internet, school_avg_ses, is_public, staff_shortage,
         school_id, country) %>%
  drop_na()

cat("Modeling dataset:", nrow(model_df), "students,",
    n_distinct(model_df$school_id), "schools,",
    n_distinct(model_df$country), "countries\n\n")

# =============================================================================
# Model 1: Null model (unconditional) — compute ICC
# How much variance is between schools/countries vs within students?
# =============================================================================

model_null <- lmer(reading_score ~ 1 + (1 | country/school_id), data = model_df)

cat("===== MODEL 1: Null (Unconditional) Model =====\n")
summary(model_null)

icc_result <- icc(model_null)
cat("\nIntraclass Correlation (ICC):\n")
print(icc_result)

# =============================================================================
# Model 2: Student-level predictors
# Does gender, SES, and internet access predict reading?
# =============================================================================

model_student <- lmer(
  reading_score ~ gender_female + ses_centered + has_internet +
    (1 | country/school_id),
  data = model_df
)

cat("\n===== MODEL 2: Student-Level Predictors =====\n")
summary(model_student)

# =============================================================================
# Model 3: Add school-level predictors
# Do school characteristics matter beyond student characteristics?
# =============================================================================

model_school <- lmer(
  reading_score ~ gender_female + ses_centered + has_internet +
    school_avg_ses + is_public + staff_shortage +
    (1 | country/school_id),
  data = model_df
)

cat("\n===== MODEL 3: Student + School-Level Predictors =====\n")
summary(model_school)

# =============================================================================
# Model 4: Cross-level interaction
# Does school SES moderate the effect of individual SES?
# (Equity question: do higher-resource schools close the SES gap?)
# =============================================================================

model_interaction <- lmer(
  reading_score ~ gender_female + ses_centered * school_avg_ses +
    has_internet + is_public + staff_shortage +
    (1 | country/school_id),
  data = model_df
)

cat("\n===== MODEL 4: Cross-Level Interaction =====\n")
summary(model_interaction)

# =============================================================================
# Model comparison
# =============================================================================

cat("\n===== MODEL COMPARISON =====\n")
comparison <- anova(model_null, model_student, model_school, model_interaction)
print(comparison)

# Compare R-squared
r2_null   <- r2(model_null)
r2_student <- r2(model_student)
r2_school <- r2(model_school)
r2_inter  <- r2(model_interaction)

cat("\nR-squared values:\n")
cat("Null model:        marginal =", round(r2_null$R2_marginal, 4),
    ", conditional =", round(r2_null$R2_conditional, 4), "\n")
cat("Student model:     marginal =", round(r2_student$R2_marginal, 4),
    ", conditional =", round(r2_student$R2_conditional, 4), "\n")
cat("School model:      marginal =", round(r2_school$R2_marginal, 4),
    ", conditional =", round(r2_school$R2_conditional, 4), "\n")
cat("Interaction model: marginal =", round(r2_inter$R2_marginal, 4),
    ", conditional =", round(r2_inter$R2_conditional, 4), "\n")

# =============================================================================
# Tidy output for the final model
# =============================================================================

tidy_results <- tidy(model_interaction, effects = "fixed", conf.int = TRUE)
cat("\nFinal model fixed effects:\n")
print(tidy_results)

# Save tidy results
write_csv(tidy_results, "data/processed/model_results.csv")

# =============================================================================
# Visualization: Coefficient plot
# =============================================================================

p_coef <- tidy_results %>%
  filter(term != "(Intercept)") %>%
  ggplot(aes(x = reorder(term, estimate), y = estimate)) +
  geom_point(size = 3, color = "#2c3e50") +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2, color = "#2c3e50") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#e74c3c") +
  coord_flip() +
  labs(
    title = "Fixed Effects from Multilevel Model",
    subtitle = "Students nested in schools nested in countries (PISA 2018)",
    x = NULL,
    y = "Estimate (with 95% CI)"
  ) +
  theme_minimal(base_size = 13)
ggsave("figures/07_coefficient_plot.png", p_coef, width = 9, height = 5, dpi = 150)

# Visualization: Random effects by country
ranef_country <- ranef(model_interaction)$country %>%
  rownames_to_column("country") %>%
  rename(intercept = `(Intercept)`) %>%
  arrange(intercept)

p_ranef <- ranef_country %>%
  ggplot(aes(x = reorder(country, intercept), y = intercept)) +
  geom_point(color = "#3498db", size = 2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  coord_flip() +
  labs(
    title = "Country-Level Random Intercepts",
    subtitle = "Deviation from overall mean reading score",
    x = NULL,
    y = "Random Intercept"
  ) +
  theme_minimal(base_size = 11)
ggsave("figures/08_country_random_effects.png", p_ranef, width = 8, height = 10, dpi = 150)

cat("\nAll model outputs and figures saved.\n")
