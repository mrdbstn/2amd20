# Read the data
aggregated_player_stats <- read.csv("~/aggregated_player_stats.csv")

# Create the scatter plot
plot(aggregated_player_stats$performance_score, aggregated_player_stats$market_value,
     main = "Market Value vs Performance Score",
     xlab = "Performance Score",
     ylab = "Market Value",
     pch = 19, # solid circle
     col = "blue") # color of points

# Fit a linear model
fit <- lm(market_value ~ performance_score, data = aggregated_player_stats)

# Add the regression line
abline(fit, col = "red", lwd = 2)

# Calculate the standard error of the regression line
preds <- predict(fit, newdata = data.frame(performance_score = aggregated_player_stats$performance_score), se.fit = TRUE)
upper_bound <- preds$fit + 2 * preds$se.fit
lower_bound <- preds$fit - 2 * preds$se.fit

# Plotting the upper and lower bounds
lines(aggregated_player_stats$performance_score, upper_bound, col = "green", lwd = 2, lty = 2)
lines(aggregated_player_stats$performance_score, lower_bound, col = "green", lwd = 2, lty = 2)

# Adding a legend
legend("topleft", legend = c("Data points", "Regression line", "2nd Std Dev Interval"),
       col = c("blue", "red", "green"), lty = c(NA, 1, 2), pch = c(19, NA, NA), lwd = 2)

# Identify players above, below, and within the 2 standard deviation bounds
above_2sd <- aggregated_player_stats$market_value > upper_bound
below_2sd <- aggregated_player_stats$market_value < lower_bound
within_2sd <- !above_2sd & !below_2sd

# Count the number of players in each category
num_above_2sd <- sum(above_2sd)
num_below_2sd <- sum(below_2sd)
num_within_2sd <- sum(within_2sd)

# Calculate the percentages
total_players <- nrow(aggregated_player_stats)
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

# Perform binomial test to check if there's a significant proportion of players above 2 standard deviations
p_value <- binom.test(num_above_2sd, total_players, p = 0.025, alternative = "greater")$p.value

# Display the p-value result
print(paste("P-value from the binomial test:", (p_value)))

# Conclusion based on the p-value
if (p_value < 0.05) {
  print("There is a significant proportion of players above 2 standard deviations from the upper green line.")
} else {
  print("There is no significant proportion of players above 2 standard deviations from the upper green line.")
}

