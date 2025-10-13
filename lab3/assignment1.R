library(plotly)
library(seriation)
library(scales)
library(dplyr)

row_data <- read.table("prices-and-earnings.txt",header =TRUE,sep="\t",stringsAsFactors=FALSE)
data <- row_data[,c(1,2,5,6,7,9,10,16,17,18,19)]
rownames(data) <- data[,1]
#data <- as.data.frame(data[,-1])
data <- data[,-1]

# step2

datacaled=scale(data)

plot_ly(x=colnames(datacaled), y=rownames(datacaled), 
        z=as.matrix(datacaled), type="heatmap", colors =colorRamp(c("yellow", "red")))
# It is extremely hard to see any clusters or outliers.

# step3 (euclidean)
rowdist<-dist(datacaled)
coldist<-dist(t(datacaled))

order1<-seriate(rowdist, "HC")
order2<-seriate(coldist, "HC")
ord1<-get_order(order1)
ord2<-get_order(order2)

reord<-datacaled[rev(ord1),ord2]
     
plot_ly(x=colnames(reord), y=rownames(reord), 
        z=reord, type="heatmap", colors =colorRamp(c("yellow", "red")))

# step3 (cor)
R_rows <- cor(t(datacaled), use = "pairwise.complete.obs")
D_r  <- as.dist(1 - R_rows)

R_cols <- cor(datacaled, use = "pairwise.complete.obs")
D_c  <- as.dist(1 - R_cols)

ord_r <- seriate(D_r, method = "HC")
o1 <- get_order(ord_r)

ord_c <- seriate(D_c, method = "HC")
o2 <- get_order(ord_c)
reord_r <- datacaled[rev(o1), o2]  

plot_ly(x = colnames(reord_r), y = rownames(reord_r), z = reord_r,
        type = "heatmap", colors = colorRamp(c("yellow","red")))


# step 4
# TSP heatmap
order1_tsp<-seriate(rowdist, "TSP")
order2_tsp<-seriate(coldist, "TSP")
ord1_tsp<-get_order(order1_tsp)
ord2_tsp<-get_order(order2_tsp)

reord_tsp<-datacaled[rev(ord1_tsp),ord2_tsp]

plot_ly(x=colnames(reord_tsp), y=rownames(reord_tsp), 
        z=reord_tsp, type="heatmap", colors =colorRamp(c("yellow", "red")))


# objective function values
hpl_hc  <- criterion(rowdist,order1, method  = "Path_length")
hpl_tsp <- criterion(rowdist,order1_tsp, method = "Path_length")

grd_hc  <- criterion(rowdist,order1, method  = "Gradient_raw")
grd_tsp <- criterion(rowdist,order1_tsp, method = "Gradient_raw")



# step5
Ps=list()
nPlot=nrow(data)

data %>%
  add_rownames( var = "group" ) %>%
  mutate_each(funs(rescale), -group) -> data_radar

for (i in 1:nPlot){
  Ps[[i]] <- htmltools::tags$div(
    plot_ly(type = 'scatterpolar', 
            r=as.numeric(data_radar[i,-1]),
            theta= colnames(data_radar)[-1], 
            fill="toself")%>%
      layout(title=data_radar$group[i]), style="width: 25%;")
}

h <-htmltools::tags$div(style = "display: flex; flex-wrap: wrap", Ps)

htmltools::browsable(h)



