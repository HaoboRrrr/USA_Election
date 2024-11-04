#### Preamble ####
# Purpose: Cleans the raw data and extract required data.
# Author: David QI
# Date: 01 November 2024
# Contact: david.qi@mail.utoronto.ca 
# License: MIT
# Pre-requisites: data in data/01-raw_data/raw_data.csv, data/01-raw_data/DJIA.csv (DJIA.csv need to be manually unzipped from archive.zip)
# Any other information needed? No

#### Workspace setup ####

library(tidyverse)
library(janitor)
library(arrow)

#### Clean data ####
data <- read_csv("data/01-raw_data/raw_data.csv") |> clean_names()
DJIA_data <- read_csv("data/01-raw_data/DJIA.csv")

### Generate State summary  $$$$
just_harris_data = data%>% filter(
     candidate_name == "Kamala Harris" )  %>% mutate(
         state = if_else(is.na(state), "National", state), # fix for national polls
         end_date = mdy(end_date)
       ) |>
     filter(end_date >= as.Date("2024-07-21"))

harris_states <-  just_harris_data %>% group_by(state) %>% 
     summarise(total_count=n(),
                             mean_pct = mean(pct),
                             .groups = 'drop') 
 
just_trump_data <- data%>% filter(
       candidate_name == "Donald Trump", )  %>% mutate(
           state = if_else(is.na(state), "National", state), # fix for national polls
           end_date = mdy(end_date)
         ) |>
    filter(end_date >= as.Date("2024-07-21"))

trump_states = just_trump_data %>% group_by(state) %>% 
     summarise(total_count=n(),
              mean_pct = mean(pct),
              .groups = 'drop')


# Filter data to Harris and Trump estimates based on high-quality polls after Harris declared entering
just_harris_high_quality <- data |>
  filter(
    candidate_name == "Kamala Harris",
    numeric_grade >= 2.5,
  ) |>
  mutate(
    state = if_else(is.na(state), "National", state), # fix for national polls
    end_date = mdy(end_date)
  ) |>
  filter(end_date >= as.Date("2024-07-21"), # When Harris declared 
         
         state %in% c("North Carolina", "Pennsylvania", "Georgia", "Nevada",
                      "Arizona", "Michigan", "Wisconsin", 
                      "National", "Maine CD-2", "Florida") # relevant states
         ) 


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

merged_summary <- harris_states %>%
  left_join(trump_states, by = c("state" = "state")) %>% mutate(abs_diff = abs(mean_pct.x - mean_pct.y)) %>% rename(mean_pct_harris = mean_pct.x, mean_pct_trump=mean_pct.y)


#### Clean DJI data $$$$
# Objective: fill the missing days with closest days.

DJIA_data$DJIA <- as.numeric(DJIA_data$DJIA)
DJIA_data <- na.omit(DJIA_data)
complete_dates <- data.frame(DATE = seq(min(DJIA_data$DATE), max(DJIA_data$DATE), by = "day"))

filled_data <- complete_dates %>%
  left_join(DJIA_data, by = "DATE")

filled_data <- filled_data %>%
  fill(DJIA)


#### Save data ####
write_parquet(merged_summary, "data/02-analysis_data/merged_summary.parquet")
write_parquet(just_harris_high_quality, "data/02-analysis_data/just_harris_high_quality.parquet")
write_parquet(just_trump_high_quality, "data/02-analysis_data/just_trump_high_quality.parquet")
write_parquet(filled_data, "data/02-analysis_data/DJIA_filled.parquet")