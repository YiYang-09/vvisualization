library(dplyr)
library(tidyr)
library(plotly)

data <- read.csv("invisible.csv")

data_new <- data %>%
  mutate(age_group = recode(age,
                            "18-29 years" = "Young",
                            "30-49 years" = "Adult",
                            "50-64 years" = "Senior")) %>%
  select(region, age_group, X2023) %>%
  pivot_wider(names_from = age_group, values_from = X2023)


#step2
p_young<- plot_ly(data_new, 
             x = ~region, 
             y = ~Young, 
             type = "violin"
             ) %>%               
  layout(title = "Income distribution by Age Group (Young)",
         xaxis = list(title = "region"),
         yaxis = list(title = "Income"))
p_young

p_adult<- plot_ly(data_new, 
                  x = ~region, 
                  y = ~Adult, 
                  type = "violin"
) %>%               
  layout(title = "Income distribution by Age Group (Adult)",
         xaxis = list(title = "region"),
         yaxis = list(title = "Income"))
p_adult

p_senior<- plot_ly(data_new, 
                  x = ~region, 
                  y = ~Senior, 
                  type = "violin"
) %>%               
  layout(title = "Income distribution by Age Group (Senior)",
         xaxis = list(title = "region"),
         yaxis = list(title = "Income"))
p_senior

df_long <- data_new %>%
  pivot_longer(cols = c(Young, Adult, Senior),
               names_to = "age_group",
               values_to = "income")
p <- plot_ly(df_long,
             x = ~age_group,
             y = ~income,
             type = "violin"
             )

p


#step3
library(plotly)

# 假设你的数据叫 data_new
p3 <- plot_ly(data = data_new, z=~Senior) %>% add_surface()
p3
