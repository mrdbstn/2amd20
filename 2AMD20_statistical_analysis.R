# Read the data
aggregated_player_stats <- read.csv("~/aggregated_df.csv")

# Filter out players with a market value below 4 million
filtered_player_stats <- aggregated_player_stats[aggregated_player_stats$market_value >= 4, ]

# Create the scatter plot
plot(filtered_player_stats$normalized_minutes_played, filtered_player_stats$market_value,
     main = "Market Value vs Performance Score",
     xlab = "Performance Score",
     ylab = "Market Value",
     pch = 19, # solid circle
     col = "blue") # color of points

# Fit a linear model
fit <- lm(market_value ~ normalized_minutes_played, data = filtered_player_stats)

# Add the regression line
abline(fit, col = "red", lwd = 2)

# Calculate the standard error of the regression line
preds <- predict(fit, newdata = data.frame(normalized_minutes_played = filtered_player_stats$normalized_minutes_played), se.fit = TRUE)
upper_bound <- preds$fit + 2 * preds$se.fit
lower_bound <- preds$fit - 2 * preds$se.fit

# Sort data for proper line plotting
sorted_index <- order(filtered_player_stats$normalized_minutes_played)
sorted_minutes_played <- filtered_player_stats$normalized_minutes_played[sorted_index]
sorted_upper_bound <- upper_bound[sorted_index]
sorted_lower_bound <- lower_bound[sorted_index]

# Plotting the upper and lower bounds
lines(sorted_minutes_played, sorted_upper_bound, col = "green", lwd = 2, lty = 2)
lines(sorted_minutes_played, sorted_lower_bound, col = "green", lwd = 2, lty = 2)

# Adding a legend
legend("topleft", legend = c("Data points", "Regression line", "2nd Std Dev Interval"),
       col = c("blue", "red", "green"), lty = c(NA, 1, 2), pch = c(19, NA, NA), lwd = 2)

# Identify players above, below, and within the 2 standard deviation bounds
above_2sd <- filtered_player_stats$market_value > upper_bound
below_2sd <- filtered_player_stats$market_value < lower_bound
within_2sd <- !above_2sd & !below_2sd

# Count the number of players in each category
num_above_2sd <- sum(above_2sd)
num_below_2sd <- sum(below_2sd)
num_within_2sd <- sum(within_2sd)

# Calculate the percentages
total_players <- nrow(filtered_player_stats)
percentage_above_2sd <- (num_above_2sd / total_players) * 100
percentage_below_2sd <- (num_below_2sd / total_players) * 100
percentage_within_2sd <- (num_within_2sd / total_players) * 100

# Display the counts and percentages
print(paste("Number of players above 2 standard deviations:", num_above_2sd))
print(paste("Percentage of players above 2 standard deviations:", round(percentage_above_2sd, 2), "%"))
print(paste("Number of players below 2 standard deviations:", num_below_2sd))
print(paste("Percentage of players below 2 standard deviations:", round(percentage_below_2sd, 2), "%"))
print(paste("Number of players within 2 standard deviations:", num_within_2sd))
print(paste("Percentage of players within 2 standard deviations:", round(percentage_within_2sd, 2), "%"))

# Print the head of the dataset of players that are deemed overvalued
overvalued_players <- filtered_player_stats[above_2sd, ]
print("Head of the dataset of overvalued players:")
print(head(overvalued_players))

# Perform a Z-test for proportions to check if there's a significant proportion of players above 2 standard deviations
expected_proportion_above <- 0.025
observed_proportion_above <- num_above_2sd / total_players
std_error <- sqrt((expected_proportion_above * (1 - expected_proportion_above)) / total_players)
z_value <- (observed_proportion_above - expected_proportion_above) / std_error
p_value <- 2 * (1 - pnorm(abs(z_value)))

# Display the p-value result
print(paste("P-value from the Z-test:", p_value))

# Conclusion based on the p-value
if (p_value < 0.05) {
  print("There is a significant proportion of players above 2 standard deviations from the upper green line.")
} else {
  print("There is no significant proportion of players above 2 standard deviations from the upper green line.")
}

# Find and print the player with the highest market value
highest_value_player <- filtered_player_stats[which.max(filtered_player_stats$market_value), ]
print("Player with the highest market value:")
print(highest_value_player)

