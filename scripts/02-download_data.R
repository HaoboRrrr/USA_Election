#### Preamble ####
# Purpose: Downloads and saves the presidential general election data from https://projects.fivethirtyeight.com/polls/president-general/2024/national/
# Author: Haobo Ren
# Date: 19 October 2024
# Contact: haobo.ren@mail.utoronto.ca



#### Workspace setup ####
library(tidyverse)

#### Download data ####
url <- "https://projects.fivethirtyeight.com/polls/data/president_polls.csv"
download.file(url, destfile = "data/01-raw_data/raw_data.csv")




         
