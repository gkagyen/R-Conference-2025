# Step 1: Load Libraries and Data
library(tidymodels)
library(tidyverse)

# Load the Air quality dataset
data("airquality")
month_levels <- unique(month.abb[airquality$Month])
data <- airquality |> 
  drop_na(Ozone) |> # remove NA's from response variable
  mutate(Month = factor(month.abb[Month], 
                               ordered = TRUE,
                               levels = month_levels)
         )
# Step 2: Data Preprocessing
# 2.1: Split data into training and testing sets
set.seed(100) # For reproducibility
split <- initial_split(data, prop = 0.8, strata = Ozone)
train_data <- training(split)
test_data <- testing(split)

# 2.2: Create a recipe for preprocessing
data_recipe <- recipe(Ozone ~ ., data = train_data) |> 
  step_impute_median(all_numeric_predictors()) |>  # Impute missing numeric values with median
  step_dummy(all_nominal_predictors()) |>  # Convert categorical variables to dummy variables
  step_normalize(all_numeric_predictors()) # Normalize numeric predictors

# Step 3: Model Specification
# Define an extreme gradient boosting model
xgb_model <- boost_tree(
  mtry = tune(), # Number of predictors to sample at each split
  trees = 1000, # Fixed number of trees
  tree_depth = tune(), # Maximum depth of trees
  min_n = tune() # Minimum number of data points in a node
) |> 
  set_engine("xgboost", nthread=3) |>  # Use xgboost package gradient boosting
  set_mode("regression") # Regression task

# Step 4: Hyperparameter Tuning
# 4.1: Create a tuning grid
xgb_grid <- grid_regular(
  mtry(range = c(1, 5)), # Range for mtry
  min_n(range = c(1, 10)), # Range for min_n
  tree_depth(range = c(1, 3)), # Range for tree_depth
  levels = 4 # Number of levels for each parameter
)

# 4.2: Set up cross-validation
set.seed(200)
data_folds <- vfold_cv(train_data, v = 10) # 10-fold cross-validation

# 4.3: Perform grid search
xgb_tune <- tune_grid(
  xgb_model,
  data_recipe,
  resamples = data_folds,
  grid = xgb_grid,
  metrics = metric_set(rmse, rsq) # Evaluate using RMSE and R-squared
)

# Step 5: Model Training and Evaluation
# 5.1: Select the best model based on RMSE
best_xgb <- select_best(xgb_tune, metric = "rmse")
print(best_xgb)

# 5.2: Finalize the workflow with the best parameters
xgb_workflow <- workflow() |> 
  add_model(xgb_model) |> 
  add_recipe(data_recipe)

final_xgb <- finalize_workflow(
  xgb_workflow,
  best_xgb
)

# 5.3: Fit the final model on the training data
final_fit <- final_xgb |>  fit(data = train_data)

# 5.4: Evaluate on the test set
test_results <- final_fit |> 
  predict(test_data) |> 
  bind_cols(test_data) |> 
  metrics(truth = Ozone, estimate = .pred)

print(test_results)

# Step 6: Make Predictions
# Predict on new data (using test set as an example)
predictions <- final_fit |>  predict(test_data)
head(predictions)

# Visualize predictions vs actual values
ggplot(data = bind_cols(predictions, test_data), 
       aes(x = Ozone, y = .pred)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, colour = "red",
              linewidth = 0.6, linetype = 'dashed') +
  labs(title = "Predicted vs Actual Sale Prices", 
       x = "Actual", y = "Predicted") +
  theme_bw()
