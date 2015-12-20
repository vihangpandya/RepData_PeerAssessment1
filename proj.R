### Question 1 - Approach 1 begins here 
### I only notice NA values for the entire day. Did not see any days with some missing vals
### Here I eleiminate all the NA values.

# Initialize by sourcing appropriate libraries.
library (datasets)
library (data.table)
#library(kernlab)
library (chron)
library (lubridate)
library (dplyr)
library (ggplot2)
library(data.table)
# Read in the data without column names
stepdat <- read.table("./activity.csv",sep = ",",skip = 1, colClasses = c("numeric",
                                                                          "Date","numeric"))
# Name the columns
cnames <- c("step","date","interval")
names(stepdat) <- make.names(cnames)
head (stepdat)
#Find the total for all 61 days
daytotal <- aggregate(list(stepdat$step), list(stepdat$date),sum, na.rm = TRUE)
head (daytotal)
# Again name the columns
names(daytotal) <- make.names(c("date","daily_total_steps"))

## Now make a histogram
hist(daytotal$daily_total_steps, col="blue", main="Total Daily Steps", xlab="Daily Total Steps", 
     breaks = 25, xlim = c(0,25000))
summary (daytotal)
### Q1 Approach 1 ends here

### Question 1 - Approach 2 begins here 

# Find the number of NAs in the dataset
## Was execting this to be 2296 (8 days wtih missing vals * 287) but observing 2304
totalNA <- sum(is.na(stepdat$step))
print (totalNA)

# For days that have all NAs replace with the mean value for all 61 days
# Mean is 9354 steps as observed in summary

#Step 1 Calculate the daily mean inclusive of NAs
#dailymeansteps <- data.frame (tapply(stepdat$step, stepdat$date, mean))
# Step 2 Name the column

# Step 3 Replace 0s in daytotal with the 9354 (daily mean of total steps)
head (daytotal)
# Create a dataframe with only one varialble of daytotal
tmpdailytotalsteps <- data.frame(daytotal$daily_total_steps)
head (tmpdailytotalsteps)
# Replace 0s and use rounding to emilminate decimal points.
tmpdailytotalsteps[(tmpdailytotalsteps == 0)] <- round(mean(daytotal$daily_total_steps),0)
# Assign proper name to the column
names(tmpdailytotalsteps) <- make.names("dailytotalsteps")
head (tmpdailytotalsteps)
# Combine with daytotal as third coulmn.
daytotal <- cbind (daytotal, tmpdailytotalsteps)
head (daytotal)

# Create a histogram that also compares the previous histogram from approach 1
par(mfrow = c (2,1))
hist(daytotal$dailytotalsteps, col="green", main="Total Daily Steps with modified NA values", 
     xlab="Daily Total Steps", breaks = 25, xlim = c(0,25000))
hist(daytotal$daily_total_steps, col="blue", main="Total Daily Steps with eliminating NA values", 
     xlab="Daily Total Steps", breaks = 25, xlim = c(0,25000))
summary (daytotal)

### End of Q1 Approach 2

### Question 2 - Convert the intervals to  factors so that we can see whihc interval has
### largest number of steps.
stepdat <- mutate (stepdat, interval = factor(interval))
# We have 288 levels
str (stepdat)
# Calculate the mean for each interval across all days.
# However since, few days have no data I will replace "NAs" for those days with the 
# average of daily datasteps (9354) divided by the number of intervals (288)
stepdat[is.na(stepdat)] <- round(mean(daytotal$dailytotalsteps)/288)


### Question 2 - First using weekdays function, I determine the days of the week for all
### 61 days.
intervalavg <- data.frame (tapply(stepdat$step, stepdat$interval, mean))
names(intervalavg) <- make.names("interval_mean_for_all_days")

# Create the timeline graph across intervals
with (intervalavg, plot(interval_mean_for_all_days, 
                        main = "Mean Interval Steps", type = "l", 
                        xlab ="Interval", ylab = "Steps"))

# Quesstion 2 - Create factors from dayofweek variable, so that we can do analysis.
# First identify which day of the week.
daytotal <- mutate (daytotal, dayofweek = weekdays(date))
# Classify into weekday or weekend
daytotal$weekend = is.weekend(daytotal$date)
str(daytotal)

#Calculate the total steps for weekend or weekday
stepsbydaytype  <- data.frame (tapply(daytotal$dailytotalsteps, daytotal$weekend, mean))
names(stepsbydaytype) <- make.names("meansteps")
print (stepsbydaytype)
with (daytotal, boxplot(dailytotalsteps ~ weekend,
                        main = "Mean Interval Steps by WorkDay and Weekend", 
                        xlab ="Type of Day", ylab = "Steps"))
axis(1, at=c("Weekday","Weekend"))
