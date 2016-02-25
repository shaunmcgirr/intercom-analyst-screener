# This script subsets the cleaned Intercom usage data to more useful datasets

## Notes
# 

## 1. Reduce the apps_on_support data to one line per Support Pro customer (unique app_id) per week
support_pro_customers_weekly_view <- apps_on_support_cleaned %>%
                                      filter(identifier == "support_pro") %>%
                                      mutate(week = week(created_at_date)) %>%
                                      distinct(app_id, week)

weekly_customers <- support_pro_customers_weekly_view %>%
                      group_by(week) %>%
                      summarise(customers_this_week = n())

length(unique(support_pro_customers_weekly_view$app_id)) #2853 unique customers over
length(unique(support_pro_customers_weekly_view$week)) # 28 weeks of data

## 2. Examine the usage data
number_of_users_per_app <- inbox_insights_events_cleaned %>%
                            group_by(app_id) %>%
                            summarise(users_per_app = n_distinct(intercom_user_id))

summary(number_of_users_per_app$users_per_app)
hist(number_of_users_per_app$users_per_app, breaks = 80)

loads_per_app_per_week <- inbox_insights_events_cleaned %>%
                            mutate(week = week(created_at)) %>%
                            group_by(app_id, week) %>%
                            summarise(loads_per_week = n()) %>%
                            mutate(adopted_this_week = 1)

# adoption_threshold <- 1

summary(loads_per_app_per_week$loads_per_week)
hist(loads_per_app_per_week$loads_per_week, breaks = 100)

weekly_adoption <- support_pro_customers_weekly_view %>%
                    left_join(loads_per_app_per_week, by = c("app_id", "week")) %>%
                    mutate(loads_per_week = ifelse(is.na(loads_per_week), 0, loads_per_week)) %>%
                    mutate(adopted_this_week = ifelse(is.na(adopted_this_week), 0, 1)) %>%
                    group_by(week) %>%
                    summarise(adoptions_this_week = sum(adopted_this_week))

summary(weekly_adoption$adopted_this_week) # 14% of observations are adoptions

## 3. Prepare a table with all three measures for graphing
weekly_adoption_rate <- weekly_customers %>%
                          left_join(weekly_adoption, by = "week") %>%
                          filter(adoptions_this_week > 0) %>%
                          transmute(Week = week,
                                    `Weekly adoption rate` = round(adoptions_this_week/customers_this_week*100, digits = 1),
                                    `Inbox Insights adoptions` = adoptions_this_week,
                                    `Support Pro customers` = customers_this_week) %>%
                          select(Week, `Weekly adoption rate`)

weekly_adoption_rate_graph <- weekly_adoption_rate %>%
                                ggplot(aes(x = Week, y = `Weekly adoption rate`)) +
                                  geom_line(colour="#000099") +
                                  ggtitle("Weekly adoption rate of Inbox Insights by Intercom Support Pro customers, May-Sep 2015\n") +
                                  labs(x = "\nWeek of 2015",
                                       y = "Weekly adoption rate (%)\n") +
                                  theme_minimal()

print(weekly_adoption_rate_graph)
ggsave("figures/weekly_adoption_rate_graph.png", width = 6, height = 3, scale = 2)


## 4. Reshape the apps_on_support data to allow calculation of weekly retention rates
# Easiest if result is table with one row per app_id and columns for each week
support_pro_customers_weekly_view_wide <- support_pro_customers_weekly_view %>%
                                            select(app_id, week) %>%
                                            filter(week > 21 & week < 37) %>%
                                            mutate(key = 1) %>%
                                            spread(week, key) %>%
                                            mutate(weeks_subscribed = rowSums(.[2:16], na.rm=T)) %>%
                                            filter(weeks_subscribed > 1) %>%
                                            mutate(retained = ifelse(is.na(`36`), 
                                                                     "not retained", 
                                                                     "retained"))

users_vs_nonusers <- loads_per_app_per_week %>%
                      group_by(app_id) %>%
                      summarise(number_of_weeks_using = n()) %>%
                      right_join(support_pro_customers_weekly_view_wide, by = "app_id") %>%
                      select(app_id, number_of_weeks_using, retained) %>%
                      mutate(user = ifelse(is.na(number_of_weeks_using), "non user", "user")) %>%
                      mutate(number_of_weeks_using = ifelse(is.na(number_of_weeks_using), 
                                                            0, number_of_weeks_using))

retention_by_weeks_usage <- users_vs_nonusers %>%
                              select(number_of_weeks_using, retained) %>%
                              group_by(number_of_weeks_using, retained) %>%
                              summarise(number_of_customers = n()) %>% ungroup() %>%
                              spread(retained, number_of_customers) %>%
                              transmute(`Number of weeks using` = as.integer(number_of_weeks_using),
                                        `Customers not retained` = as.integer(ifelse(is.na(`not retained`),
                                                                          0, `not retained`)),
                                        `Customers retained` = as.integer(retained),
                                        `Retention rate` = as.integer(round(`Customers retained`/(`Customers retained`+`Customers not retained`)*100, digits=0)))

table_for_latex <- xtable(retention_by_weeks_usage)
print(table_for_latex, include.rownames = F)
                                        

## 4. Other usage patterns
plot(wday(inbox_insights_events_cleaned$created_at_date, label = T), main = "All Inbox Insights usage by day of week, May-Sep 2015")
