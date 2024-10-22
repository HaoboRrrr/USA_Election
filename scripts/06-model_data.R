#### Preamble ####
# Purpose: 
# Author: David Qi
# Date: 22 Oct 2024
# Contact: david.qi@mail.utoronto.ca 
# License: MIT
# Pre-requisites: data in "data/02-analysis_data/DJIA_filled.csv", "data/02-analysis_data/just_harris_high_quality.csv"
# Any other information needed? No


#### Workspace setup ####
library(tidyverse)

#### Read data ####
polling_data <- read_csv("data/02-analysis_data/just_harris_high_quality.csv") %>% select(pct, start_date,end_date)
DJIdata = read_csv("data/02-analysis_data/DJIA_filled.csv")

### Model data ####
# prepare data

# Convert the date columns to Date format
polling_data$start_date <- as.Date(polling_data$start_date, format = "%m/%d/%y")
polling_data$end_date <- as.Date(polling_data$end_date, format = "%m/%d/%y")

# Create a data frame to store merged data
merged_data <- polling_data %>%
  # Left join with DJIdata based on dates, shifting for lag
  left_join(DJIdata, by = c("end_date" = "DATE")) %>%
  rename(DJIA_today = DJIA)

# Create lagged variables for DJIA
merged_data <- merged_data %>%
  arrange(end_date) %>%
  # Create lagged variables
  mutate(DJIA_lag_1 = lag(DJIA_today, n = 1),
         DJIA_lag_7 = lag(DJIA_today, n = 7),
         DJIA_lag_14 = lag(DJIA_today, n = 14),
         DJIA_lag_28 = lag(DJIA_today, n = 28),
         DJIA_lag_60 = lag(DJIA_today, n = 60),
         DJIA_lag_90 = lag(DJIA_today, n = 90),
         )

# Remove rows with NA values (may occur due to lagging)
merged_data <- na.omit(merged_data)

# Fit the linear regression model
model <- lm(pct ~  DJIA_lag_60 + DJIA_lag_90, data = merged_data)

# Summarize the model
summary(model)


#### Save model ####


