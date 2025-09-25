library(readxl)
library(plotly)
library(MASS)
library(dplyr)
library(tidyr)
library(gridExtra)

data <- read_xlsx("baseball-2016.xlsx")  
#MDS is based on distance, but the dimensions of the data variables vary greatly, which will affect the judgment of MDS.

#step2

data.numeric= scale(data[,3:28])
d=dist(data.numeric)

res=isoMDS(d,k=2)
coords=res$points

coordsMDS=as.data.frame(coords)
coordsMDS$name=rownames(coordsMDS)
coordsMDS$League=data$League
coordsMDS$Team=data$Team


plot_ly(coordsMDS, x=~V1, y=~V2, type="scatter", hovertext=~Team, color= ~League)

#There is a slight difference, but not strong. 
#AL teams are more distributed above the x-axis and to the right of the y-axis.
#NL teams are more distributed below the x-axis and to the right of the y-axis.
#Therefore, the two leagues are more distinguishable along the y-axis.
# Boston Red Sox seems to be an outlier.

#step3


sh <- Shepard(d, coords)
delta <-as.numeric(d)
D<- as.numeric(dist(coords))

n=nrow(coords)
index=matrix(1:n, nrow=n, ncol=n)
index1=as.numeric(index[lower.tri(index)])

n=nrow(coords)
index=matrix(1:n, nrow=n, ncol=n, byrow = T)
index2=as.numeric(index[lower.tri(index)])



plot_ly()%>%
  add_markers(x=~delta, y=~D, hoverinfo = 'text',
              text = ~paste('Obj1: ', rownames(data)[index1],
                            '<br> Obj 2: ', rownames(data)[index2]))%>%
  #if nonmetric MDS inolved
  add_lines(x=~sh$x, y=~sh$yf)

# relatively successful, as can be seen from the figure, the results fit very well and the points basically fit the curve.
# When $delta$ is between 6 and 8, a few points are below the line, indicating that the distance between these points after mapping is too close.
# When $delta$ is between 8 and 10, a few points are above the line, indicating that the distance between these points after mapping is too far.
# When $delta$ is greater than 10, almost all points are difficult to map for MDS.

#step4
best_dim <- "V2"

num_df <- data[, 3:28]
num_names <- names(num_df)


cors <- sapply(num_names, function(vname) {
  cor(num_df[[vname]], coordsMDS[[best_dim]], use = "complete.obs", method = "pearson")
})

cors_sorted <- sort(cors, decreasing = FALSE)
top2 <- names(sort(abs(cors), decreasing = TRUE))[1:2]
print(cors[top2])

plot_ly(coordsMDS, x=~V2, y=~num_df[[top2[1]]], type="scatter", hovertext=~Team, color= ~League) %>%
  layout(
    xaxis = list(title = best_dim),
    yaxis = list(title = top2[1])
  )

plot_ly(coordsMDS, x=~V2, y=~num_df[[top2[2]]], type="scatter", hovertext=~Team, color= ~League)  %>%
  layout(
    xaxis = list(title = best_dim),
    yaxis = list(title = top2[2])
  )
#HR and HR per game showed the strongest positive correlation.
#Home runs are a significant predictor of both scoring and winning percentage, so V2 can be interpreted as a dimension of team offensive intensity, with significant differences across leagues.
