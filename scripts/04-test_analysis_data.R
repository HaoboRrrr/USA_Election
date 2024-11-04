#### Preamble ####
# Purpose: Test for analysis data
# Author: David QI
# Date: 01 November 2024
# Contact: david.qi@mail.utoronto.ca 
# License: MIT
# Pre-requisites: DJIA_filled.parquet, just_trump_high_quality.parquet, just_harris_high_quality.parquet are in data/02-analysis_data
# Any other information needed? No.


#### Workspace setup ####
library(tidyverse)
library(arrow)

harris_data <- read_parquet("data/02-analysis_data/just_harris_high_quality.parquet") %>% select(pct, start_date,end_date,question_id,state)
trump_data <- read_parquet("data/02-analysis_data/just_trump_high_quality.parquet") %>% select(pct, start_date,end_date,question_id,state)
DJIA_data = read_parquet("data/02-analysis_data/DJIA_filled.parquet")

# Test if the data was successfully loaded
if (exists("harris_data")) {
  message("Test Passed: The Harris dataset was successfully loaded.")
} else {
  stop("Test Failed: The Harris dataset could not be loaded.")
}

if (exists("trump_data")) {
  message("Test Passed: The Trump dataset was successfully loaded.")
} else {
  stop("Test Failed: The Trump dataset could not be loaded.")
}

if (exists("DJIA_data")) {
  message("Test Passed: The DJIA dataset was successfully loaded.")
} else {
  stop("Test Failed: The DJIA dataset could not be loaded.")
}

#### Test Harris data ####

# Check if there are any negative values
if (all(harris_data$pct >= 0)) {
  message("Test Passed: Harris support rates are non-negative")
} else {
  stop("Test Failed: There exist nagative Harris support rate.")
}

# Check if there are any missing values
if (all(!is.na(harris_data))) {
  message("Test Passed: The Harris dataset contains no missing values.")
} else {
  stop("Test Failed: The Harris dataset contains missing values.")
}

# Check if there are duplicates
if (!any(duplicated(harris_data))) {
  message("Test Passed: The Harris dataset contains no duplicates.")
} else {
  stop("Test Failed: The Harris dataset contains duplicates.")
}

# Check if data only include relevant states
if (all(harris_data$state %in% c("North Carolina", "Pennsylvania", "Georgia", "Nevada",
                                "Arizona", "Michigan", "Wisconsin", 
                                "National", "Maine CD-2", "Florida"))){
  message("Test Passed: Harris Data set only contain data for relevant states")
}else{
  stop("Test Failed: Harris data set have for states that we are not modeling")
}

#### Test Trump data ####

# Check if there are any negative values
if (all(trump_data$pct >= 0)) {
  message("Test Passed: Trump support rates are non-negative")
} else {
  stop("Test Failed: There exist nagative Trump support rate.")
}

# Check if there are any missing values
if (all(!is.na(trump_data))) {
  message("Test Passed: The Trump dataset contains no missing values.")
} else {
  stop("Test Failed: The Trump dataset contains missing values.")
}

# Check if there are duplicates
if (!any(duplicated(trump_data))) {
  message("Test Passed: The Trump dataset contains no duplicates.")
} else {
  stop("Test Failed: The Trump dataset contains duplicates.")
}

# Check if data only include relevant states
if (all(trump_data$state %in% c("North Carolina", "Pennsylvania", "Georgia","Nevada", 
                                "Arizona", "Michigan", "Wisconsin", 
                                "National", "Maine CD-2", "Florida"))){
  message("Test Passed: Trump Data set only contain data for relevant states")
}else{
  stop("Test Failed: Trump data set have for states that we are not modeling")
}

#### Test Harris and Trump data combined ####

# Check if support rate add to value less than 100
total <- merge(harris_data,trump_data,by="question_id") #create a cache dataset that merges the two
if (all(total$pct.x + total$pct.y <= 100)) {
  message("Test Passed: support rate adds up to less than 100")
} else {
  stop("Test Failed: support rate adds up to value greater than 100")
}

# Check if data only include relevant states

if (all(total$state %in% c("North Carolina", "Pennsylvania", "Georgia", 
             "Arizona", "Michigan", "Wisconsin", 
             "National", "Maine CD-2", "Florida"))){
  message("Test Passed: Data set only contain data for relevant states")
}else{
  stop("Test Failed: We have data for states that we are not modeling")
}

# Check if the questionnaires are the same
if (all(harris_data$question_id %in% trump_data$question_id) & length(harris_data$question_id) == length(trump_data$question_id)) {
  message("Test Passed: Harris and Trump dataset are from the same set of questionnaires")
} else {
  stop("Test Failed: Harris and Trump dataset are from the different set of questionnaires")
}

#### Test DJIA data ####

# Check if there are any negative values
if (all(DJIA_data$DJIA > 0)) {
  message("Test Passed: DJIA index are all positive")
} else {
  stop("Test Failed: there exist non-positive DJIA values")
}

# Check if We have DJIA data for relevant dates. 

# Generating a list of relevant dates
relevant_dates = {}
for(date in harris_data$end_date){
  date = as.Date(date)
  relevant_dates = c(seq(date - 365, date, by = "day"),relevant_dates) # All dates in the 1 year range of the end dates. 
}
relevant_dates = relevant_dates[!duplicated(relevant_dates)]

# test if ve have the DJIA data for these dates
if (all(relevant_dates %in% DJIA_data$DATE)) {
  message("Test Passed: We have DJIA index for all relevent dates.")
} else {
  stop("Test Failed: We don't have DJIA index for all relevent dates.")
}