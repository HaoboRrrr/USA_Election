#### Preamble ####
# Purpose: Cleans the raw data and extract required data.
# Author: David QI
# Date: 01 November 2024
# Contact: david.qi@mail.utoronto.ca 
# License: MIT
# Pre-requisites: data in data/01-raw_data/raw_data.csv, data/01-raw_data/DJIA.csv (DJIA.csv need to be manually unzipped from archive.zip)
# Any other information needed? No

#### Workspace setup ####

library(ggplot2)
library(tidyverse)
library(janitor)
library(lubridate)
# TODO: check if all these libraries are needed


#### Clean data ####
data <- read_csv("data/01-raw_data/raw_data.csv") |> clean_names()

# Filter data to Harris and Trump estimates based on high-quality polls after Harris declared entering
just_harris_high_quality <- data |>
  filter(
    candidate_name == "Kamala Harris",
    numeric_grade >= 2.5
  ) |>
  mutate(
    state = if_else(is.na(state), "National", state), # fix for national polls
    end_date = mdy(end_date)
  ) |>
  filter(end_date >= as.Date("2024-07-21")) # When Harris declared


# filter out the same set of questionnaires for Trump 
just_trump_high_quality <- data |>
  filter(
    candidate_name == "Donald Trump",
    question_id %in% just_harris_high_quality$question_id
  ) |>
  mutate(
    state = if_else(is.na(state), "National", state), # fix for national polls
    end_date = mdy(end_date)
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
write_csv(just_trump_high_quality, "data/02-analysis_data/just_trump_high_quality.csv")
write_csv(filled_data , "data/02-analysis_data/DJIA_filled.csv")