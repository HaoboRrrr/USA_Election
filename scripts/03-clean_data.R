#### Preamble ####
# Purpose: Cleans the raw data and extract required data.
# Author: David QI
# Date: 22 Oct 2024
# Contact: david.qi@mail.utoronto.ca 
# License: MIT
# Pre-requisites: data in data/01-raw_data/raw_data.csv, data/01-raw_data/DJIA.csv
# Any other information needed? No

#### Workspace setup ####

library(ggplot2)
library(tidyverse)
library(janitor)
library(lubridate)
library(broom)
library(modelsummary)
library(rstanarm)
library(splines)
library(dplyr)
library(tidyr)
# TODO: check if all these libraries are needed


#### Clean data ####
data <- read_csv("data/01-raw_data/raw_data.csv") |> clean_names()

# Filter data to Harris estimates based on high-quality polls after she declared
just_harris_high_quality <- data |>
  filter(
    candidate_name == "Kamala Harris",
    numeric_grade >= 2.7 # Need to investigate this choice - come back and fix. 
    # Also need to look at whether the pollster has multiple polls or just one or two - filter out later
  ) |>
  mutate(
    state = if_else(is.na(state), "National", state), # Hacky fix for national polls - come back and check
    end_date = mdy(end_date)
  ) |>
  filter(end_date >= as.Date("2024-07-21")) |> # When Harris declared
  mutate(
    num_harris = round((pct / 100) * sample_size, 0) # Need number not percent for some models
  )

#### Plot data ####
base_plot <- ggplot(just_harris_high_quality, aes(x = end_date, y = pct)) +
  theme_classic() +
  labs(y = "Harris percent", x = "Date")
base_plot +
  geom_point() +
  geom_smooth()

#### Clean DJI data $$$$
# Objective: fill the missing days with closest days.
DJIdata <- read_csv("data/01-raw_data/DJIA.csv")

DJIdata$DJIA <- as.numeric(DJIdata$DJIA)
DJIdata <- na.omit(DJIdata)
complete_dates <- data.frame(DATE = seq(min(DJIdata$DATE), max(DJIdata$DATE), by = "day"))

filled_data <- complete_dates %>%
  left_join(DJIdata, by = "DATE")

filled_data <- filled_data %>%
  fill(DJIA)


#### Save data ####
write_csv(just_harris_high_quality, "data/02-analysis_data/just_harris_high_quality.csv")
write_csv(filled_data , "data/02-analysis_data/DJIA_filled.csv")