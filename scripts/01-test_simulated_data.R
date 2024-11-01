#### Preamble ####
# Purpose: Tests the structure and validity of the simulated Data
# Author: David Qi 
# Date: 30 October 2024
# Contact: david.qi@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
  # - The `tidyverse` package must be installed and loaded
  # - 00-simulate_data.R must have been run
# Any other information needed? Make sure you are in the `starter_folder` rproj


#### Workspace setup ####
library(tidyverse)

poll_results <- read_csv("data/00-simulated_data/simulated_data_poll.csv")
stock_results <- read_csv("data/00-simulated_data/simulated_data_stock.csv")

# Test if the data was successfully loaded
if (exists("poll_results")) {
  message("Test Passed: The dataset was successfully loaded.")
} else {
  stop("Test Failed: The dataset could not be loaded.")
}

if (exists("stock_results")) {
  message("Test Passed: The dataset was successfully loaded.")
} else {
  stop("Test Failed: The dataset could not be loaded.")
}

#### Test Poll data ####

# Check if the dataset has 50 rows
if (nrow(poll_results) == 50) {
  message("Test Passed: The dataset has 50 rows.")
} else {
  stop("Test Failed: The dataset does not have 50 rows.")
}

# Check if the dataset has 8 columns
if (ncol(poll_results) == 8) {
  message("Test Passed: The dataset has 8 columns.")
} else {
  stop("Test Failed: The dataset does not have 8 columns.")
}

# Check if support rate add to value close enough to 100 (error less than error from floating point (we use 10^-9 here))
if (all(abs(poll_results$Harris_reg + poll_results$Trump_reg + poll_results$Other_reg - 100) < 10^-9)) {
  message("Test Passed: support rate adds up to exactly 100")
} else {
  stop("Test Failed: support rate adds up to value other than 100")
}

# Check if We have stock data for relevant dates.
if (all(poll_results$end_dates %in% stock_results$dates)) {
  message("Test Passed: We have DJIA index for all relevent dates.")
} else {
  stop("Test Failed: We don't have DJIA index for all relevent dates.")
}

# Check if there are any negative values
if (all(poll_results$Harris_reg>= 0) & all(poll_results$Trump_reg>= 0 & all(poll_results$Other_reg>= 0))) {
  message("Test Passed: Support rates are non-negative")
} else {
  stop("Test Failed: There exist nagative support rate.")
}

# Check if there are any missing values
if (all(!is.na(poll_results))) {
  message("Test Passed: The dataset contains no missing values.")
} else {
  stop("Test Failed: The dataset contains missing values.")
}


#### Test DJIA data ####

# Check if the 'stock_data' column has at least two unique values
if (n_distinct(stock_results$stock_data) >= 2) {
  message("Test Passed: The 'stock_data' column contains at least two unique values.")
} else {
  stop("Test Failed: The 'party_data' column contains less than two unique values.")
}

# Check if there are any negative values
if (all(stock_results$stock_data > 0)) {
  message("Test Passed: DJIA index are all positive")
} else {
  stop("Test Failed: there exist non-positive DJIA values")
}

# Check if there are any missing values
if (all(!is.na(stock_results))) {
  message("Test Passed: The stock dataset contains no missing values.")
} else {
  stop("Test Failed: The stock dataset contains missing values.")
}