################################################################
### PREPARATION: LOAD LIBRARIES AND CREATE DATA
################################################################

# Step 0: Install and Load Robyn
# If you haven't installed Robyn yet, uncomment and run the line below
# remotes::install_github("facebookexperimental/Robyn/R")
library(Robyn)

set.seed(123)
data_points <- 150

my_data <- data.frame(
  DATE = seq.Date(from = as.Date("2022-01-01"), by = "week", length.out = data_points),
  google_search_brand = runif(data_points, min = 5000, max = 25000),
  youtube_brand = runif(data_points, min = 10000, max = 40000),
  facebook_reels = runif(data_points, min = 10000, max = 40000),
  facebook_instagram = runif(data_points, min = 10000, max = 40000),
  Tiktok = runif(data_points, min = 10000, max = 40000),
  snapchat = runif(data_points, min = 3000, max = 15000)
)

# You defined the "true" relationships for revenue
true_revenue <- 100000 +
  (my_data$google_search_brand * 0.8) +
  (my_data$youtube_brand * 0.5) +         
  (my_data$facebook_reels * 0.7) +
  (my_data$facebook_instagram * 0.9) +
  (my_data$Tiktok * 0.3) +
  (my_data$snapchat * 0.2)

# Add some randomness (noise) to make it more realistic
noise <- rnorm(data_points, mean = 0, sd = 5000)
my_data$revenue <- true_revenue + noise

print("--- Data successfully created! ---")
head(my_data)

################################################################
### ROBYN SCRIPT SETUP
################################################################

# Step 2: Set the Working Directory for Model Outputs
# IMPORTANT: Change this path to a folder that exists on YOUR computer.
# All charts and model files will be saved here.
robyn_object <- "/Users/chriscespedes/Documents/mktScience/mktScience_Robyn_MMM" 

# Step 3: Define Your Inputs for Robyn
# This function tells Robyn everything about your data and settings.
InputCollect <- robyn_inputs(
  dt_input = my_data,
  date_var = "DATE",
  dep_var = "revenue",
  dep_var_type = "revenue",
  
  # Identify which columns are your paid media marketing spend
  paid_media_spends = c(
    "google_search_brand",
    "youtube_brand",
    "facebook_reels",
    "facebook_instagram",
    "Tiktok",
    "snapchat"
  ),
  
  # Set the date range for modeling
  window_start = "2022-01-01",
  window_end = "2024-11-17", # Adjust if your data range changes
  
  # Define the adstock type
  adstock = "geometric"
)
print(InputCollect)


# Step 4: Define Hyperparameter Ranges
# These are the "rules" or boundaries for the model to search within.
# Using the default recommended ranges is a great starting point.
hyperparameters <- list(
  google_search_brand_alphas = c(0.5, 3),
  google_search_brand_gammas = c(0.3, 1),
  google_search_brand_thetas = c(0, 0.3),
  
  youtube_brand_alphas = c(0.5, 3),
  youtube_brand_gammas = c(0.3, 1),
  youtube_brand_thetas = c(0.1, 0.4),
  
  facebook_reels_alphas = c(0.5, 3),
  facebook_reels_gammas = c(0.3, 1),
  facebook_reels_thetas = c(0, 0.3),
  
  facebook_instagram_alphas = c(0.5, 3),
  facebook_instagram_gammas = c(0.3, 1),
  facebook_instagram_thetas = c(0, 0.3),
  
  Tiktok_alphas = c(0.5, 3),
  Tiktok_gammas = c(0.3, 1),
  Tiktok_thetas = c(0, 0.3),
  
  snapchat_alphas = c(0.5, 3),
  snapchat_gammas = c(0.3, 1),
  snapchat_thetas = c(0, 0.3)
)

# <<< THIS IS THE FIX - STEP 4.1 >>>
# Add the hyperparameters list into the main InputCollect object
InputCollect <- robyn_inputs(InputCollect = InputCollect, hyperparameters = hyperparameters)
print(InputCollect)
################################################################
### MODEL EXECUTION AND OUTPUT
################################################################

# Step 5: Run the Model
# This is where the magic happens! Robyn will build thousands of models.
# This step will take several minutes to run.
OutputModels <- robyn_run(
  InputCollect = InputCollect,
  hyperparameters = hyperparameters,
  iterations = 2000,
  trials = 5,
  cores = 6, # IMPORTANT: Adjust this to the number of cores on your computer
  robyn_object = robyn_object
)
print(OutputModels)


# Step 6: Explore the Results and Select a Model
# This function generates plots and summaries to help you choose the best model.
# After running this, look at the plots window in RStudio.
# You will also be prompted in the R Console to enter a model ID (e.g., "1_50_3").
OutputCollect <- robyn_outputs(
  InputCollect,
  OutputModels,
  # The "pareto_fronts" argument lets you choose how many model sets to see.
  # 'auto' is a good default.
  pareto_fronts = "auto", 
  robyn_object = robyn_object
)
print(OutputCollect)


# After you have selected a model ID in the console, you can proceed to save the results.
# The `robyn_save` function will export all the charts, data, and model information
# for your chosen model into the folder you specified in `robyn_object`.
# You will be prompted again in the console to confirm your model selection.

# print(OutputCollect$allSolutions) # Uncomment to see all model IDs
# robyn_save(
#   robyn_object = robyn_object,
#   select_model = "1_50_3", # <-- CHANGE THIS to the ID you want to save
#   InputCollect = InputCollect,
#   OutputCollect = OutputCollect
# )