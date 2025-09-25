library(shiny)
library(ggplot2)
library(gridExtra)

### Basic function from previous steps

func1 <- function(column){
  
  quantiles <- quantile(column,probs=c(0.25,0.75))
  greater <- quantiles[2] + 1.5*(quantiles[2] - quantiles[1])
  less <- quantiles[1] - 1.5*(quantiles[2] - quantiles[1])
  
  ind1 <- which(column<less)
  ind2 <- which(column>greater)
  
  ind <- c(ind1,ind2)
  return(ind)
}

var_name <- c("Length of Stay","Age","Infection Risk","Routine Culturing Ratio",
              "Routine Chest X-ray Ratio","Number of Beds","Medical School Affiliation","Region","Average Daily Census",
              "Number of Nurses","Available Facilities & Services")

plot_func <- function(df, column, bw_adj = 1) {
  values <-  df[,colnames(df)==column]
  number_var <- which(colnames(df)==column)
  outliers <- func1(values)
  plot_df <- data.frame(
    value = values,
    outlier = rep(FALSE, length(values))
  )
  plot_df$outlier[outliers] <- TRUE
  
  p <- ggplot(plot_df, aes(x = value)) +
    geom_density(fill = "lightblue", alpha = 0.5, bw = bw_adj) +
    geom_point(
      data = subset(plot_df, outlier),
      aes(x = value, y = 0),
      shape = 23, size = 2.5, color = "red", fill = "red"
    ) +
    labs(title = paste("Density of", var_name[number_var-1])) +
    theme_minimal()
  
  return(p)
}

txt_f <- read.table("SENIC.txt", header = FALSE)



ui <- fluidPage(
  titlePanel("Densities"),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput(
        "vars", "choose variables：",
        choices = paste0("V", c(2:7,10:12)),
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
