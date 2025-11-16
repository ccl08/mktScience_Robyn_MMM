# --- 0. Load Libraries ---
library(Robyn)
library(dplyr)

# --- 1. Create Data (with all fixes) ---
set.seed(123)
data_points <- 150

my_data <- data.frame(
  DATE = seq.Date(from = as.Date("2022-01-01"), by = "week", length.out = data_points),
  google_search_brand = runif(data_points, min = 5000, max = 25000),
  youtube_brand = runif(data_points, min = 10000, max = 40000), # Column is 'youtube_brand'
  facebook_reels = runif(data_points, min = 10000, max = 40000),
  facebook_instagram = runif(data_points, min = 10000, max = 40000),
  Tiktok = runif(data_points, min = 10000, max = 40000),
  snapchat = runif(data_points, min = 3000, max = 15000)
)

true_revenue <- 100000 +
  (my_data$google_search_brand * 0.8) +
  (my_data$youtube_brand * 0.5) +         # <-- FIXED: Was 'youtube'
  (my_data$facebook_reels * 0.7) +
  (my_data$facebook_instagram * 0.9) +
  (my_data$Tiktok * 0.3) +
  (my_data$snapchat * 0.2)

noise <- rnorm(data_points, mean = 0, sd = 5000)
my_data$revenue <- true_revenue + noise

print("--- Data successfully created! ---")
head(my_data)

# --- 2. Run Step 1: robyn_inputs() ---
data(dt_prophet_holidays) # Make sure holidays are loaded

InputCollect_synthetic <- robyn_inputs(
  dt_input = my_data,
  dt_holidays = dt_prophet_holidays,
  date_var = "DATE",
  dep_var = "revenue",
  dep_var_type = "revenue",
  paid_media_spends = c("google_search_brand", 
                        "youtube_brand", 
                        "facebook_reels", 
                        "facebook_instagram", 
                        "Tiktok", 
                        "snapchat"),
  prophet_country = "UK",  
  adstock = "weibull_pdf"
)

# --- 3. Run Step 2: VERIFY Hyperparameters ---
# This step is critical. You should see a long list of parameters.
print("--- Verifying hyperparameters... ---")
print(InputCollect_synthetic$hyperparameters)

# --- 4. Run Step 3: robyn_run() ---
# This will only work if Step 3 successfully prints the list
print("--- Starting robyn_run() (this will take a few minutes)... ---")
OutputModels_synthetic <- robyn_run(
  InputCollect = InputCollect_synthetic,
  cores = NULL, # Uses all available CPU cores (minus one)
  iterations = 2000, # Number of models to test
  trials = 5         # Number of "best" model chains to run
)

print("--- robyn_run() is complete! ---")
