library(tidymodels)
library(lubridate)
library(tidyverse)
library(mice)

# --------------------------------------------------------------------------
# 1. Load and Prepare Data (Monthly Weather Data)
# --------------------------------------------------------------------------
weather_data <- read_csv('data/ghana_weather_monthly.csv', show_col_types = F)
View(weather_data)
glimpse(weather_data)

# impute missing values
impute_data <- weather_data |> 
  select(Rainfall, Humidity, Temperature) # select data to impute
impute <- mice(impute_data, method='pmm', printFlag = FALSE)
imputed <- complete(impute, 1)

# get complete data with no missing values
weather_data_complete <- weather_data |> select(Date) |> 
  bind_cols(as_tibble(imputed)) |> 
  mutate(Month = month(Date, label = TRUE)) # add a month column
head(weather_data_complete)

# visualise trends
weather_data_complete |> pivot_longer(-(c(Date,Month))) |> 
  ggplot(aes(x = Date, y = value, colour = name)) +
  geom_line(linewidth = 0.6, show.legend = FALSE) + 
  labs(x = 'Time Duration', y = 'Recorded Values',
       title = 'Weather Data from 2019 to 2024',
       caption = 'NB: This is just a synthetic data') +
  scale_x_date(breaks = breaks_width('1 year'), date_labels = '%Y') +
  facet_wrap(~ name, scale = 'free_y') +
  theme_minimal() + 
  theme(plot.title = element_text(hjust = 0.5, face = 'bold'))


# --------------------------------------------------------------------------
# 2. Split into Training and Future Data
# --------------------------------------------------------------------------
set.seed(1999)
split <- initial_split(weather_data_complete, prop = 0.75)
wt_training <- training(split)
wt_testing <- testing(split)


# --------------------------------------------------------------------------
# 3. Create Feature Engineering Recipe
# --------------------------------------------------------------------------
wt_recipe <- recipe(Rainfall ~ ., data = wt_training) |> 
  step_rm(Date) |>                    # Remove original date
  step_zv(all_predictors()) |>        # remove various with single unique values
  step_dummy(all_nominal_predictors()) |>  
  step_normalize(all_numeric_predictors())


# --------------------------------------------------------------------------
# 4. Model Specification (Random Forest)
# --------------------------------------------------------------------------
# define random forest model
rf_model <- rand_forest(
  mtry = tune(), # Number of predictors to sample at each split
  trees = 1000, # Fixed number of trees
  min_n = tune() # Minimum number of data points in a node
) |> 
  set_engine("ranger") |>  
  set_mode("regression") 


# --------------------------------------------------------------------------
# 5. Tune Model Hyperparameters
# --------------------------------------------------------------------------
# create a search grid for parameters
rf_grid <- grid_regular(
  mtry(range = c(1,4)),
  min_n(range = c(2,13)),
  levels = 5
)

# cross validation
rf_folds <- vfold_cv(wt_training, v = 10)

# tune the parameters
rf_tune <- tune_grid(
  rf_model,
  wt_recipe,
  resamples = rf_folds,
  grid = rf_grid,
  metrics = metric_set(rmse, rsq, mae) # Evaluate using RMSE, R-squared and MAE
)


# -------------------------------------------------------------------------
# 6. Train and Evaluate Model
# -------------------------------------------------------------------------
# select best outcome from the hyperparameter tuning
best_rf <- select_best(rf_tune, metric = "mae")
print(best_rf)

# finalize the workflow with the best parameters
rf_workflow <- workflow() |> 
  add_model(rf_model) |> 
  add_recipe(wt_recipe)

final_rf <- finalize_workflow(
  rf_workflow,
  best_rf
)

final_fit <- final_rf |>  fit(data = wt_training)

# evaluate on the test set
test_results <- final_fit |> 
  predict(wt_testing) |> 
  bind_cols(wt_testing) |> 
  metrics(truth = Rainfall, estimate = .pred)
test_results


# -------------------------------------------------------------------------
# 7. Make Predictions and Visualise
# -------------------------------------------------------------------------
# Predict on new data (using test set as an example)
predictions <- final_fit |>  predict(wt_testing)
head(predictions)

# Visualize predictions vs actual values as scatter plot
ggplot(data = bind_cols(predictions, wt_testing), 
       aes(x = Rainfall, y = .pred)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, colour = "red",
              linewidth = 0.6, linetype = 'dashed') +
  labs(title = "Predicted vs Actual Sale Prices", 
       x = "Actual", y = "Predicted") +
  theme_bw()

# Visualise prediction vs actual as trends
wt_testing |> bind_cols(predictions) |> 
  select(Date, Rainfall, .pred) |> pivot_longer(-Date) |> 
  ggplot(aes(x = Date, y = value)) + 
  geom_line(aes(colour = name), linewidth = 0.6) + 
  scale_colour_manual(values = c('black', 'blue'), 
                      labels = c('Actual', 'Predicted')) + 
  labs(colour = 'Rainfall') +
  theme_bw() + 
  theme(legend.position = 'top')
  











