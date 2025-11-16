# Load the Robyn library
library(Robyn)
library(dplyr)
data(dt_simulated_weekly)

head(dt_simulated_weekly)

set.seed (123)

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

# --- 2. Define the "True" Revenue Relationship ---
true_revenue <- 100000 +                                      # Base sales
  (my_data$google_search_brand * 0.8) +     # True ROI
  (my_data$youtube * 0.5) +                 # True ROI
  (my_data$facebook_reels * 0.7) +          # True ROI
  (my_data$facebook_instagram * 0.9) +      # True ROI
  (my_data$Tiktok * 0.3) +                  # True ROI
  (my_data$snapchat * 0.2)                  # True ROI

# --- 3. Add realistic "noise" ---
noise <- rnorm(data_points, mean = 0, sd = 5000)

# --- 4. Add the final 'revenue' column to your data frame ---
my_data$revenue <- true_revenue + noise

# --- 5. Check your final, complete dataset! ---
print("--- Data successfully created! ---")
head(my_data)


InputCollect_synthetic <- robyn_inputs(
  dt_input = my_data,
  dt_holidays = dt_prophet_holidays,  # The master list of all holidays
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

print(InputCollect_synthetic)

