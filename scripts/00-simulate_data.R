#### Preamble ####
# Purpose: Simulates a dataset of polling results, which include polls and the support rate of Kamala Harris and Donald Trump. And simulate DJIA index. 
# Author: David Qi
# Date: 30 October 2024
# Contact: david.qi@mail.utoronto.ca
# License: MIT
# Pre-requisites: The `tidyverse` package must be installed
# Any other information needed? Make sure you are in the `starter_folder` rproj


#### Workspace setup ####
library(tidyverse)
set.seed(853)


#### Simulate data ####


n_polls <- 50   # Number of polls
mean_support_harris <- 45 # Average support for Kamala Harris (%)
mean_support_trump <- 45  # Average support for Donald Trump (%)
mean_support_other<- 10 # Average support for Other Candidates added together (%)
sd_TrumpHarris_poll <- 3             # Standard deviation of random error for Trump and Harris
sd_Other_poll <- 0.5            # Standard deviation of random error for sum of Other Candidates
dates <- seq(as.Date("2024-09-12"),as.Date("2024-10-31"),by = "day")


# Simulate polling results
poll_results <- data.frame(
  Poll = 1:n_polls,
  end_dates <- dates,
  Harris = pmax(0, pmin(100, rnorm(n_polls, mean = mean_support_harris, sd = sd_TrumpHarris_poll))),
  Trump = pmax(0, pmin(100, rnorm(n_polls, mean = mean_support_trump, sd = sd_TrumpHarris_poll))),
  Other = pmax(0, pmin(100, rnorm(n_polls, mean = mean_support_other, sd = sd_Other_poll)))
)

poll_results <- poll_results %>% mutate(
  Harris_reg = 100 * Harris/(Harris + Trump + Other), # regularized 
  Trump_reg = 100 * Trump/(Harris + Trump + Other),
  Other_reg = 100 * Other/(Harris + Trump + Other),
)

# Simulate stock market data
start_value <- 40000
mean_change <- 10
sd_change <- 300
stock_data = 1:50

stock_data[1] = start_value
for (i in 2:50) {
  stock_data[i] = stock_data[i-1] + rnorm(1,mean = mean_change,sd = sd_change)
}

stock_results <- data.frame(
  dates <- dates,
  stock_data = stock_data
)


#### Save data ####
write_csv(poll_results, "data/00-simulated_data/simulated_data_poll.csv")
write_csv(stock_results, "data/00-simulated_data/simulated_data_stock.csv")
