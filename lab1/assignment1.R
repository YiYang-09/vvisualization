txt_f <- read.table("SENIC.txt", header = FALSE)  

func1 <- function(column){
  
  quantiles <- quantile(column,probs=c(0.25,0.75))
  greater <- quantiles[2] + 1.5*(quantiles[2] - quantiles[1])
  less <- quantiles[1] - 1.5*(quantiles[2] - quantiles[1])
  
  ind1 <- which(column<less)
  ind2 <- which(column>greater)
  
  ind <- c(ind1,ind2)
  return(ind)
}

#step3
library(ggplot2)

infection_risk <- txt_f[,4]
outliers <- func1(infection_risk)
df <- data.frame(
  infection_risk = infection_risk,
  outlier = FALSE
)
df$outlier[outliers] <- TRUE   

p3 <- ggplot(df, aes(x = infection_risk)) +
  geom_density() +
  geom_point(
    data = subset(df, outlier),
    aes(x = infection_risk, y = 0),
    shape = 23, size = 3, color = "red", fill = "red"
  ) +
  labs(x = "Infection risk", y = "Density",
       title = "Density of Infection Risk with Outliers (◇)") +
  theme_minimal()
p3
# Most hospitals are in the medium risk range, but there are still a few
# hospitals that show extreme high risk or low risk.

#step4
library(gridExtra)

plot_func <- function(df, column, bw_adj = 1) {
  values <-  df[,colnames(df)==column]
  outliers <- func1(values)
  plot_df <- data.frame(
    value = values,
    outlier = rep(FALSE, length(values))
  )
  plot_df$outlier[outliers] <- TRUE
  
  p <- ggplot(plot_df, aes(x = value)) +
    geom_density(fill = "lightblue", alpha = 0.5, adjust = bw_adj) +
    geom_point(
      data = subset(plot_df, outlier),
      aes(x = value, y = 0),
      shape = 23, size = 2.5, color = "red", fill = "red"
    ) +
    labs(title = paste("Density of", column)) +
    theme_minimal()
  
  return(p)
}


all_vars <- paste0("V", 2:12)
plots <- lapply(all_vars, function(v) plot_func(txt_f, v))

grid.arrange(grobs = plots, ncol = 3)
#


#step5
ggplot(txt_f, aes(x = V11, y = V4, color = V7)) +
  geom_point() +
  scale_color_viridis_c(name = "Beds (V7)",direction = -1) +
  labs(x = "Number of Nurses (V11)", y = "Infection Risk (V4, %)") +
  theme_minimal()

# The density plot in Step 4 only shows the individual distribution and outliers of each variable.
# But this scatter plot reveals an interactive relationship: the number of nurses and the number of beds are highly correlated.
# With the same number of nurses, hospitals of different sizes have different infection risks.

# The number of beds and the number of nurses actually provide similar information, namely the size of the hospital, 
# so the number of nurses and the number of beds are strongly correlated,
# but the color gradient here can mislead people about the impact of the number of beds on the risk of infection.


#step6
library(plotly)
ggplotly(p3)


#step7
library(dplyr)
out_idx  <- func1(txt_f$V4)
df7 <- txt_f %>%
  select(id = V1, infection_risk = V4) %>%
  mutate(outlier = is.element(id, out_idx))

plot7 <- df7 %>% plot_ly() %>% add_histogram(x=~infection_risk, nbinsx=50, name="infection risk") %>%
  add_markers(data = df7 %>% filter(outlier),
              x=~infection_risk,y=0,
              name="outliers",
              marker = list(symbol = "diamond",
                            size = 10, color = "red"))
plot7


#step8
library(shiny)

ui <- fluidPage(
  titlePanel("Densities"),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput(
        "vars", "choose variables（V2–V12）：",
        choices = paste0("V", 2:12),
        selected = c("V4", "V2", "V11")
      ),
      sliderInput(
        "bw_adj", "bw：",
        min = 0.3, max = 3, value = 1, step = 0.1
      )
    ),
    mainPanel(
      plotOutput("panel", height = "720px")
    )
  )
)

server <- function(input, output, session){
  
  output$panel <- renderPlot({
    req(input$vars)
    
    plots <- lapply(
      input$vars,
      function(v) plot_func(txt_f, v, bw_adj = input$bw_adj)
    )
    
    do.call(grid.arrange, c(plots, ncol = input$ncol))
  })
}
shinyApp(ui, server)
