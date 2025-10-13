library("visNetwork")
library("igraph")
library("ggraph")

#step 1: 
links <- read.table("trainData.dat",header = FALSE,fileEncoding =  "latin1")
nodes <- read.table("trainMeta.dat",header = FALSE,fileEncoding =  "latin1")

nodes[,3] <- 1:nrow(nodes) 
nodes <- nodes[,c(3,1,2)]

colnames(nodes) <- c("id","name","bombingGroup")
colnames(links) <- c("from","to","weight")

#Collapsing multiple links into one
links <- aggregate(weight ~ from + to, data = links, FUN = sum) 
links <- links[order(links$from,links$to),]

rownames(links) <- NULL
#label the nodes
nodes$label <- nodes$name

## nodes colored by Bombing Group
nodes$group=nodes$bombingGroup

## size of node by number of connections ---igraph-strength
#1 create igraph object
net <- graph_from_data_frame(d=links,vertices = nodes,directed = F)
#2 use strength()
nodes$value <- strength(net,mode = "all",weight=E(net)$weight)

links$width=links$weight #


visNetwork(nodes, links)%>%visPhysics(solver="repulsion")%>%#optimize repulsion force
  visOptions(highlightNearest = TRUE) 

#analysis: Based on the repulsion-based layout algorithm, nodes with stronger connections are automatically positioned closer together. In the network visualization, the large blue nodes in the central region are densely interconnected and surrounded by smaller nodes, forming a clearly identifiable cluster.

#The yellow nodes are more dispersed compared to the blue ones, but still form several peripheral clusters. For example, in the lower right corner, there is a cluster centered around large yellow nodes such as `Imad Eddin Barakat`. In the lower left, another cluster is formed around `Abdelkarim el Mejjati`. In the upper right, `Semaan Gaby Eid` and the surrounding nodes constitute yet another cluster.

#Through manual inspection of the network layout, we can roughly identify four distinct clusters

#step 2:
visNetwork(nodes, links)%>%visPhysics(solver="repulsion")%>%#optimize repulsion force
  visOptions(highlightNearest =  list(enabled = TRUE, degree = 2, hover = TRUE)) 
#analysis:
#Jamal Zougam had the best opportunity to spread information within the network, as indicated by his high node strength and central position in the graph. According to Wikipedia, Zougam (born 5 October 1973) was one of the individuals convicted for the 2004 Madrid train bombings. He was arrested on 13 March 2004 and charged with multiple counts of murder, attempted murder, vehicle theft, membership in a terrorist organization, and four counts of carrying out terrorist acts (Wikipedia – 2004 Madrid train bombings)

#step 3:
##community identification
nodes1<-nodes
net <- graph_from_data_frame(d=links, vertices=nodes, directed=F)
ceb <- cluster_edge_betweenness(net) 
nodes1$group=ceb$membership
visNetwork(nodes1,links)%>%visIgraphLayout()

table(ceb$membership)
# By optimizing edge betweenness, we can still observe the four main clusters identified in the initial step. However, in addition to those, the cluster originally surrounding `Semaan Gaby Eid` in the upper part of the network has been further subdivided into two distinct communities. Overall, we can identify five major clusters, along with several smaller ones of more limited size.


#step 4 : 
netm <- get.adjacency(net, attr="weight", sparse=F)

rowdist<-dist(netm)

library(seriation)
order1<-seriate(rowdist, "HC")
ord1<-get_order(order1)

reordmatr<-netm[ord1,ord1]

library(plotly)

plot_ly(z=~reordmatr, x=~colnames(reordmatr), 
        y=~rownames(reordmatr), type="heatmap")

#The heatmap reveals a pronounced cluster in the upper-right quadrant, characterized by high interaction values among individuals such as `Jamal Zougam`. This cluster corresponds closely to the community identified in Step 1 through visual inspection and in Step 3 via edge betweenness clustering.
