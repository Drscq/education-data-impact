# =============================================================================
# 04_eda.R
# Exploratory data analysis — descriptive statistics and visualizations
#
# Skills demonstrated: Fundamental statistics, R/tidyverse, data visualization
# =============================================================================

library(tidyverse)

# --- Load data ---
df <- read_csv("data/processed/analysis_data.csv")

# ---- 1. Descriptive statistics ----

# Overall summary
summary_stats <- df %>%
  summarise(
    n              = n(),
    mean_reading   = mean(reading_score, na.rm = TRUE),
    sd_reading     = sd(reading_score, na.rm = TRUE),
    median_reading = median(reading_score, na.rm = TRUE),
    min_reading    = min(reading_score, na.rm = TRUE),
    max_reading    = max(reading_score, na.rm = TRUE),
    mean_ses       = mean(ses_index, na.rm = TRUE),
    sd_ses         = sd(ses_index, na.rm = TRUE),
    pct_female     = mean(gender_female, na.rm = TRUE) * 100,
    pct_internet   = mean(has_internet, na.rm = TRUE) * 100
  )
cat("Overall descriptive statistics:\n")
print(summary_stats)

# By-country summary
country_summary <- df %>%
  group_by(country) %>%
  summarise(
    n            = n(),
    avg_reading  = round(mean(reading_score, na.rm = TRUE), 1),
    sd_reading   = round(sd(reading_score, na.rm = TRUE), 1),
    avg_ses      = round(mean(ses_index, na.rm = TRUE), 2),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_reading))

cat("\nCountry-level summary (top 15):\n")
print(head(country_summary, 15))

# ---- 2. Visualizations ----

theme_set(theme_minimal(base_size = 13))

# Plot 1: Distribution of reading scores
p1 <- ggplot(df, aes(x = reading_score)) +
  geom_histogram(bins = 50, fill = "#3498db", color = "white", alpha = 0.8) +
  labs(
    title = "Distribution of PISA Reading Scores (2018)",
    x = "Reading Score",
    y = "Count"
  )
ggsave("figures/01_reading_distribution.png", p1, width = 8, height = 5, dpi = 150)

# Plot 2: Reading by gender (boxplot)
p2 <- df %>%
  filter(!is.na(gender)) %>%
  ggplot(aes(x = gender, y = reading_score, fill = gender)) +
  geom_boxplot(alpha = 0.7, show.legend = FALSE) +
  scale_fill_manual(values = c("female" = "#e74c3c", "male" = "#3498db")) +
  labs(
    title = "Reading Scores by Gender",
    x = "Gender",
    y = "Reading Score"
  )
ggsave("figures/02_reading_by_gender.png", p2, width = 6, height = 5, dpi = 150)

# Plot 3: SES vs Reading (scatter with trend)
p3 <- df %>%
  sample_n(min(2000, nrow(df))) %>%  # sample for readability
  ggplot(aes(x = ses_index, y = reading_score)) +
  geom_point(alpha = 0.15, color = "#2c3e50", size = 0.8) +
  geom_smooth(method = "lm", color = "#e74c3c", linewidth = 1.2) +
  labs(
    title = "Socioeconomic Status and Reading Achievement",
    x = "SES Index (ESCS)",
    y = "Reading Score"
  )
ggsave("figures/03_ses_vs_reading.png", p3, width = 8, height = 5, dpi = 150)

# Plot 4: Top 20 countries bar chart
p4 <- country_summary %>%
  head(20) %>%
  ggplot(aes(x = reorder(country, avg_reading), y = avg_reading)) +
  geom_col(fill = "#2ecc71", alpha = 0.85) +
  geom_text(aes(label = avg_reading), hjust = -0.1, size = 3.2) +
  coord_flip() +
  labs(
    title = "Top 20 Countries by Average Reading Score",
    x = NULL,
    y = "Average Reading Score"
  )
ggsave("figures/04_top_countries.png", p4, width = 8, height = 7, dpi = 150)

# Plot 5: Internet access and reading (for non-technical audience)
p5 <- df %>%
  filter(!is.na(internet)) %>%
  group_by(internet) %>%
  summarise(avg_reading = mean(reading_score, na.rm = TRUE), .groups = "drop") %>%
  ggplot(aes(x = internet, y = avg_reading, fill = internet)) +
  geom_col(alpha = 0.8, show.legend = FALSE, width = 0.5) +
  geom_text(aes(label = round(avg_reading, 1)), vjust = -0.5, size = 5) +
  scale_fill_manual(values = c("no" = "#e67e22", "yes" = "#27ae60")) +
  ylim(0, max(df$reading_score, na.rm = TRUE) * 0.8) +
  labs(
    title = "Average Reading Score: Students With vs Without Internet",
    subtitle = "PISA 2018 data across all participating countries",
    x = "Internet Access at Home",
    y = "Average Reading Score"
  )
ggsave("figures/05_internet_reading.png", p5, width = 7, height = 5, dpi = 150)

# Plot 6: Correlation heatmap of numeric variables
numeric_vars <- df %>%
  select(reading_score, math_score, science_score, ses_index, has_internet, gender_female) %>%
  drop_na()

cor_matrix <- cor(numeric_vars)

cor_long <- cor_matrix %>%
  as.data.frame() %>%
  rownames_to_column("var1") %>%
  pivot_longer(-var1, names_to = "var2", values_to = "correlation")

p6 <- ggplot(cor_long, aes(x = var1, y = var2, fill = correlation)) +
  geom_tile(color = "white") +
  geom_text(aes(label = round(correlation, 2)), size = 3.5) +
  scale_fill_gradient2(low = "#3498db", mid = "white", high = "#e74c3c", midpoint = 0) +
  labs(title = "Correlation Matrix of Key Variables") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title = element_blank())
ggsave("figures/06_correlation_matrix.png", p6, width = 7, height = 6, dpi = 150)

cat("\nAll figures saved to figures/\n")
