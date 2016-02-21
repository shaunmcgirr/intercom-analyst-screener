# This script assembles the CSVs in to a useable structure

## Notes
# 

## 0. Unzip the files received
unzip("data_raw/screener_new_data.zip", overwrite = T, exdir = "data_raw")

## 1. Load inbox_insights_events.csv
inbox_insights_events_raw <- read.csv(file = "data_raw/inbox_insights_events.csv",
                                      colClasses = "character", sep = ",",
                                      strip.white = T, blank.lines.skip = T,
                                      nrows = 41921) 

# Lots of strange data here, could be a trick!
summary_of_string_lengths <- apply(inbox_insights_events_raw, 2, function(x) table(nchar(x)))
  print(summary_of_string_lengths)

# app_id, admin_id look like they need some treatment, for now just filter them out
inbox_insights_events_cleaned <- inbox_insights_events_raw %>%
                                  filter(nchar(app_id) < 10) %>%
                                  filter(4 < nchar(admin_id) & nchar(admin_id) < 7)

# This subsetting drops ~8% of the data
dim(inbox_insights_events_cleaned)
summary_of_string_lengths <- apply(inbox_insights_events_cleaned, 2, function(x) table(nchar(x)))
  print(summary_of_string_lengths)
  
# Based on examination of other file below, decided to leave unfiltered for now
inbox_insights_events_cleaned <- inbox_insights_events_raw; rm(inbox_insights_events_raw)
  
# Code columns to more useful data types
inbox_insights_events_cleaned$admin_id <- as.factor(inbox_insights_events_cleaned$admin_id)

inbox_insights_events_cleaned$created_at <- parse_date_time(inbox_insights_events_cleaned$created_at, 
                                                            orders = c("Y m d H M S"),
                                                            tz = "UTC")

inbox_insights_events_cleaned$created_at_date <- dmy(inbox_insights_events_cleaned$created_at_date)

# Quickly check the dates agree! (they do)
# inbox_insights_events_cleaned$dates_same <- ymd(as.Date(inbox_insights_events_cleaned$created_at)) - inbox_insights_events_cleaned$created_at_date
# summary(as.numeric(inbox_insights_events_cleaned$dates_same))

inbox_insights_events_cleaned$interval <- as.integer(inbox_insights_events_cleaned$interval)

## 2. Same for other data file
apps_on_support_raw <- read.csv(file = "data_raw/apps_on_support.csv",
                                        colClasses = "character", sep = ",",
                                        strip.white = T, blank.lines.skip = T) 
  
# Check for unexpected data
summary_of_string_lengths <- apply(apps_on_support_raw, 2, function(x) table(nchar(x)))
  print(summary_of_string_lengths) # Some app_id are 40 characters long, so leave (and leave above)

apps_on_support_cleaned <- apps_on_support_raw; rm(apps_on_support_raw)
  
# Code columns to more useful data types (created_at is really only a date, not date-time)
apps_on_support_cleaned$created_at_date <- parse_date_time(apps_on_support_cleaned$created_at, 
                                                      orders = c("Y m d H M S"),
                                                      tz = "UTC")

apps_on_support_cleaned$identifier <- as.factor(apps_on_support_cleaned$identifier)
  
