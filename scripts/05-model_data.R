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

#### Read data ####
harris_data <- read_csv("data/02-analysis_data/just_harris_high_quality.csv") %>% select(pct, start_date,end_date)
trump_data <- read_csv("data/02-analysis_data/just_trump_high_quality.csv") %>% select(pct, start_date,end_date)
DJIA_data = read_csv("data/02-analysis_data/DJIA_filled.csv")

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
         DJIA_lag_180 = lag(DJIA, n = 180),
  )

merged_harris_data <- harris_data %>%
  # Left join with DJIA_data based on dates, shifting for lag
  left_join(DJIA_data, by = c("end_date" = "DATE")) 

# Remove rows with NA values (may occur due to lagging)
merged_harris_data <- na.omit(merged_harris_data)

# Fit the linear regression model
model_harris <- lm(pct ~ 0+DJIA_lag_7+DJIA_lag_14 +DJIA_lag_60 +DJIA_lag_90+ DJIA_lag_180, data = merged_harris_data)

# Summarize the model
summary(model_harris)
AIC(model_harris)

# Recorded AIC of tested models: 
# 0+DJIA_lag_60 + DJIA_lag_180: 4361.658
# DJIA_lag_60 + DJIA_lag_180: 4363.403
# DJIA_lag_14+DJIA_lag_60 + DJIA_lag_180: 4363.68
# DJIA_lag_7 + DJIA_lag_14+DJIA_lag_28+DJIA_lag_60 +DJIA_lag_90+ DJIA_lag_180: 4351.305
# DJIA_lag_7 +DJIA_lag_28+DJIA_lag_60 +DJIA_lag_90+ DJIA_lag_180: 4349.33
# 0+DJIA_lag_7 +DJIA_lag_28+DJIA_lag_60 +DJIA_lag_90+ DJIA_lag_180:4347.386
# 0+DJIA_lag_7 +DJIA_lag_60 +DJIA_lag_90+ DJIA_lag_180: 4346.483
# DJIA_lag_7 +DJIA_lag_60 +DJIA_lag_90+ DJIA_lag_180: 4348.452
# DJIA_lag_7 + DJIA_lag_14 +DJIA_lag_90: 4368.93
# 0+DJIA_lag_7+DJIA_lag_14 +DJIA_lag_60 +DJIA_lag_90+ DJIA_lag_180: 4348.404

merged_trump_data <- trump_data %>%
  # Left join with DJIA_data based on dates, shifting for lag
  left_join(DJIA_data, by = c("end_date" = "DATE")) %>%
  rename(DJIA = DJIA)

# Remove rows with NA values (may occur due to lagging)
merged_trump_data <- na.omit(merged_trump_data)

# Fit the linear regression model
model_trump <- lm(pct ~  0+DJIA_lag_7+DJIA_lag_14 +DJIA_lag_60 +DJIA_lag_90+ DJIA_lag_180, data = merged_trump_data)

# Summarize the model
summary(model_trump)
AIC(model_trump)

# Recorded AIC of tested models: 
# 0+DJIA_lag_60 + DJIA_lag_180: 4416.838
# DJIA_lag_60 + DJIA_lag_180: 4415.838
# DJIA_lag_14+DJIA_lag_60 + DJIA_lag_180: 4392.898
# DJIA_lag_7 + DJIA_lag_14+DJIA_lag_28+DJIA_lag_60 +DJIA_lag_90+ DJIA_lag_180: 4392.119
# DJIA_lag_7 + DJIA_lag_14+DJIA_lag_60 +DJIA_lag_90+ DJIA_lag_180: 4390.328
# DJIA_lag_7 + DJIA_lag_14 +DJIA_lag_90+ DJIA_lag_180: 4388.661
# DJIA_lag_7 + DJIA_lag_14 +DJIA_lag_90: 4387.064
# 0+DJIA_lag_7 + DJIA_lag_14 +DJIA_lag_90: 4387.54
# DJIA_lag_14 +DJIA_lag_90: 4388.565
# DJIA_lag_7 +DJIA_lag_28+DJIA_lag_60 +DJIA_lag_90+ DJIA_lag_180: 4404.42
# 0+DJIA_lag_7 +DJIA_lag_28+DJIA_lag_60 +DJIA_lag_90+ DJIA_lag_180:4402.483
# 0+DJIA_lag_7 +DJIA_lag_60 +DJIA_lag_90+ DJIA_lag_180: 4401.229
# DJIA_lag_7 +DJIA_lag_60 +DJIA_lag_90+ DJIA_lag_180: 4403.22
# 0+DJIA_lag_7+DJIA_lag_14 +DJIA_lag_60 +DJIA_lag_90+ DJIA_lag_180: 4388.33

acf(resid(model_trump))
pacf(resid(model_trump))

acf(resid(model_harris))
pacf(resid(model_harris))


#### Save model ####
saveRDS(model_harris, file = "models/model_harris.rds")
saveRDS(model_trump, file = "models/model_trump.rds")
