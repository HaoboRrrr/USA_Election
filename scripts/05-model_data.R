#### Preamble ####
# Purpose: Test various models and choose one to save
# Author: David Qi
# Date: 22 Oct 2024
# Contact: david.qi@mail.utoronto.ca 
# License: MIT
# Pre-requisites: data in "data/02-analysis_data/DJIA_filled.csv", "data/02-analysis_data/just_harris_high_quality.csv", "data/02-analysis_data/just_trump_high_quality.csv"
# Any other information needed? No


#### Workspace setup ####
library(tidyverse)
library(arrow)

#### Read data ####
harris_data <- read_parquet("data/02-analysis_data/just_harris_high_quality.parquet") %>% select(pct, start_date,end_date,question_id,state)
trump_data <- read_parquet("data/02-analysis_data/just_trump_high_quality.parquet") %>% select(pct, start_date,end_date,question_id,state)
DJIA_data = read_parquet("data/02-analysis_data/DJIA_filled.parquet")

### Model data ####
# prepare data

# Convert the date columns to Date format
harris_data$start_date <- as.Date(harris_data$start_date, format = "%m/%d/%y")
harris_data$end_date <- as.Date(harris_data$end_date, format = "%m/%d/%y")

# Create a data frame to store merged data

DJIA_data = DJIA_data %>%  # Create lagged variables
  mutate(DJIA_lag_1 = lag(DJIA, n = 1),
         DJIA_lag_7 = lag(DJIA, n = 7),
         DJIA_lag_14 = lag(DJIA, n = 14),
         DJIA_lag_28 = lag(DJIA, n = 28),
         DJIA_lag_60 = lag(DJIA, n = 60),
         DJIA_lag_90 = lag(DJIA, n = 90),
         DJIA_lag_120 = lag(DJIA, n = 120),
         DJIA_lag_150 = lag(DJIA, n = 150),
         DJIA_lag_180 = lag(DJIA, n = 180),
  )

merged_harris_data <- harris_data %>%
  # Left join with DJIA_data based on dates, shifting for lag
  left_join(DJIA_data, by = c("end_date" = "DATE")) 

# Remove rows with NA values (may occur due to lagging)
merged_harris_data <- na.omit(merged_harris_data)

# Model

# Fit the linear regression model
model_harris <- lm(pct ~  DJIA_lag_7 + DJIA_lag_14+DJIA_lag_28+DJIA_lag_60 + DJIA_lag_150+ DJIA_lag_180+state,data = merged_harris_data)


# Summarize the model
summary(model_harris)
AIC(model_harris)

# Recorded AIC of tested models: 
# DJIA_lag_7 + DJIA_lag_14+DJIA_lag_28+DJIA_lag_60 +DJIA_lag_90+DJIA_lag_120+DJIA_lag_150+ DJIA_lag_180+state: 2785.518
# DJIA_lag_7 + DJIA_lag_14+DJIA_lag_60 +DJIA_lag_90+DJIA_lag_120+DJIA_lag_150+ DJIA_lag_180+state: 2783.721
# DJIA_lag_7 + DJIA_lag_14 +DJIA_lag_90+DJIA_lag_120+DJIA_lag_150+ DJIA_lag_180+state: 2781.809(best AIC) 
# DJIA_lag_7 + DJIA_lag_14 +DJIA_lag_120+DJIA_lag_150+ DJIA_lag_180+state: 2782.749
# DJIA_lag_7 + DJIA_lag_14 + DJIA_lag_90 + DJIA_lag_150 + DJIA_lag_180 + state: 2784.388
# DJIA_lag_7 + DJIA_lag_14 + DJIA_lag_150 + DJIA_lag_180 + state: 2783.104
# DJIA_lag_14 + DJIA_lag_150 + DJIA_lag_180 + state: 2790.254
# DJIA_lag_14+DJIA_lag_28+DJIA_lag_60 + DJIA_lag_150+ DJIA_lag_180+state: 2793.49
# DJIA_lag_7 + DJIA_lag_14+DJIA_lag_28+DJIA_lag_60 + DJIA_lag_150+ DJIA_lag_180+state: 2785.338 (Chosen)


merged_trump_data <- trump_data %>%
  # Left join with DJIA_data based on dates, shifting for lag
  left_join(DJIA_data, by = c("end_date" = "DATE")) %>%
  rename(DJIA = DJIA)

# Remove rows with NA values (may occur due to lagging)
merged_trump_data <- na.omit(merged_trump_data)

# Fit the linear regression model
model_trump <- lm(pct ~  DJIA_lag_7 + DJIA_lag_14+DJIA_lag_28+DJIA_lag_60 + DJIA_lag_150+ DJIA_lag_180+state, data = merged_trump_data)

# Summarize the model
summary(model_trump)
AIC(model_trump)

# Recorded AIC of tested models: 
# DJIA_lag_7 + DJIA_lag_14+DJIA_lag_28+DJIA_lag_60 +DJIA_lag_90+DJIA_lag_120+DJIA_lag_150+ DJIA_lag_180+state: 2819.526
# DJIA_lag_14+DJIA_lag_28+DJIA_lag_60 +DJIA_lag_90+DJIA_lag_120+DJIA_lag_150+ DJIA_lag_180+state: 2818.029
# DJIA_lag_7 + DJIA_lag_14 +DJIA_lag_28 +DJIA_lag_90+DJIA_lag_120+DJIA_lag_150+ DJIA_lag_180+state: 2823.345
# DJIA_lag_7 + DJIA_lag_14 +DJIA_lag_90+DJIA_lag_120+DJIA_lag_150+ DJIA_lag_180+state: 2821.546
# DJIA_lag_7 + DJIA_lag_14+DJIA_lag_28+DJIA_lag_60 +DJIA_lag_90+ DJIA_lag_150+ DJIA_lag_180+state: 2817.58
# DJIA_lag_14+DJIA_lag_28+DJIA_lag_60 +DJIA_lag_90+ DJIA_lag_150+ DJIA_lag_180+state: 2816.102 (best AIC)
# DJIA_lag_14+DJIA_lag_28+DJIA_lag_60 + DJIA_lag_150+ DJIA_lag_180+state: 2816.666 
# DJIA_lag_7+ DJIA_lag_14+DJIA_lag_28+DJIA_lag_60 + DJIA_lag_150+ DJIA_lag_180+state: 2818.401 (Chosen)


acf(resid(model_trump))
pacf(resid(model_trump))

acf(resid(model_harris))
pacf(resid(model_harris))


#### Save model ####
saveRDS(model_harris, file = "models/model_harris.rds")
saveRDS(model_trump, file = "models/model_trump.rds")