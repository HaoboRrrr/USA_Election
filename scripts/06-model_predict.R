#### Preamble ####
# Purpose: make prediction using the model
# Author: David Qi
# Date: 04 Nov 2024
# Contact: david.qi@mail.utoronto.ca 
# License: MIT
# Pre-requisites: Model are complete and saved in "models/", cleaned DJIA data saved in "data/02-analysis_data/DJIA_filled.parquet"
# Any other information needed? No


#### Workspace setup ####
library(tidyverse)
library(arrow)

model_harris = readRDS(file = here::here("models/model_harris.rds"))

model_trump = readRDS(file = here::here("models/model_trump.rds"))

DJIA_data = read_parquet("data/02-analysis_data/DJIA_filled.parquet")

# Set the target date
target_date <- as.Date("2024-11-05")


# States to predict
states_to_predict <- c("North Carolina", "Pennsylvania", "Georgia", 
                       "Arizona","Nevada", "Michigan", "Wisconsin", "Maine CD-2", "Florida", 
                       "National")



DJIA_values <- DJIA_data %>% filter(DATE %in% c(
  target_date - 7,
  target_date - 14,
  target_date - 28,
  target_date - 60,
  target_date - 150,
  target_date - 180
))


  # Create a new data frame for the current state
new_data <- data.frame(
    DJIA_lag_7   = rep(DJIA_values$DJIA[6],10),
    DJIA_lag_14  = rep(DJIA_values$DJIA[5],10),
    DJIA_lag_28  = rep(DJIA_values$DJIA[4],10),
    DJIA_lag_60  = rep(DJIA_values$DJIA[3],10),
    DJIA_lag_150 = rep(DJIA_values$DJIA[2],10),
    DJIA_lag_180 = rep(DJIA_values$DJIA[1],10),
    state        = states_to_predict
  )
  

predictions_trump <- predict(model_trump, newdata = new_data,interval="confidence")

predictions_harris <- predict(model_harris, newdata = new_data,interval="confidence")


#### Monte Carlo simulation ####
set.seed(304)

predictions_trump_se <- predict(model_trump, newdata = new_data,se.fit = TRUE)
predictions_harris_se <- predict(model_harris, newdata = new_data,se.fit = TRUE)
standard_errors_trump <- predictions_trump_se$se.fit
fit_trump <- predictions_trump_se$fit
standard_errors_harris <- predictions_harris_se$se.fit
fit_harris <- predictions_harris_se$fit

monte_carlo_result = 1:10

for (i in 1:10){
  count = 0
  for (c in 1:100000){
    if((standard_errors_trump[i]* rt(1,df = 597) + fit_trump[i])  > (standard_errors_harris[i]* rt(1,df = 597) + fit_harris[i])){
      count  = count +1
    } #597 degree of freedom
  }
  monte_carlo_result[i] = count/100000
}

votes = c(16, 19, 16, 11, 6, 15, 10, 1, 30) # electoral vote for each state
democratic_mean = 0
republican_mean = 0
national_result = 0
national_draw = 0

for (c in 1:1000000){
  democratic = 226
  republican = 188
  
  for (i in 1:9){
    if((standard_errors_trump[i]* rt(1,df = 597) + fit_trump[i])  > (standard_errors_harris[i]* rt(1,df = 597) + fit_harris[i])){
       democratic = democratic + votes[i]
    } else{
      republican = republican + votes[i]
    }
  }
  republican_mean = republican_mean + republican
  democratic_mean = democratic_mean + democratic
  
  if(republican>269 ){
    national_result  = national_result +1
  }else if(republican == 269){
    national_draw  = national_draw +1
  }
}


results<- tibble(
  state = states_to_predict,
  prediction_trump = predictions_trump[, "fit"],
  lower_ci_trump = predictions_trump[, "lwr"],
  upper_ci_trump = predictions_trump[, "upr"],
  prediction_harris = predictions_harris[, "fit"],
  lower_ci_harris = predictions_harris[, "lwr"],
  upper_ci_harris = predictions_harris[, "upr"],
  result = ifelse(predictions_trump[, "fit"] - predictions_harris[, "fit"] > 0,"Trump Win","Harris win"),
  trump_win_rate = monte_carlo_result
)

#### Save prediction ####
write_parquet(results, "models/prediction_results.parquet")

print(paste0("republican wins ", national_result, " out of 1000000 simulation. There are ",national_draw, " draws" ))
print(paste0("mean electorial votes for democratic: ", democratic_mean/1000000, " mean electorial votes for republican: ",republican_mean/1000000 ))

