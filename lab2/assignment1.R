library(ggplot2)
library(dplyr)
library(gridExtra)
library(plotly)

data <- read.csv("olive.csv")

# step1

ggplot(data,mapping = aes(x=oleic, y=palmitic, color = linoleic)) +
  geom_point() +
  scale_color_gradient(  low = "#56B1F7",
                         high = "#132B43") +
  labs(title = "Palmitic vs Oleic colored by continuous Linoleic",
       x = "Oleic",
       y = "Palmitic") +
    theme_minimal() 

               
p_color <- ggplot(data,mapping = aes(x=oleic, y=palmitic, color = cut_interval(linoleic,4))) +
  geom_point() +
  scale_color_brewer(palette = "Set1") +
  labs(title = "Palmitic vs Oleic colored by continuous Linoleic",
       x = "Oleic",
       y = "Palmitic") +
  theme_minimal()

p_color
#When we only use a single color dimension to express numerical values, 
#the human eye cannot quickly and accurately perceive the numerical differences. 
#However, dividing the numerical values into several discrete color categories becomes a feature of "color classification", 
#which is easier to be quickly distinguished by pre-attention processing.

# step2

# color class is as previous plot.

p_size <- ggplot(data, aes(x = oleic, y = palmitic, size = cut_interval(linoleic,4))) +
  geom_point(alpha = 0.6) +
  labs(title = "Palmitic vs Oleic (Linoleic (Size)") +
  theme_minimal()


angles <- c(0, pi/4, pi/2, 3*pi/4)
data <- data %>%
  mutate(Linoleic_angle = as.numeric(cut_interval(linoleic,4)),
         angle = angles[Linoleic_angle])

p_angle <- ggplot(data, aes(x = oleic, y = palmitic)) +
  geom_spoke(aes(angle = angle, radius = 25), 
             ) +
  labs(title = "Palmitic vs Oleic (Linoleic (Orientation)") +
  theme_minimal()

grid.arrange(grobs = list(p_color,p_size,p_angle), ncol = 2)
#

# step3
ggplot(data,mapping = aes(x=eicosenoic, y=oleic, color = Region)) +
  geom_point() +
  scale_color_gradient(  low = "#56B1F7",
                         high = "#132B43") +
  labs(title = " Oleic vs Eicosenoic  colored by Region",
       x = "Eicosenoic",
       y = "Oleic") +
  theme_minimal()
#Region values have no real distance relationship.
#Using continuous colors will blur the boundaries between categories and produce mixed colors, making it difficult to separate groups at a glance.
#And it will mislead readers to interpret Region as a numerical variable.

ggplot(data,mapping = aes(x=eicosenoic, y=oleic, color = as.factor(Region))) +
  geom_point() +
  scale_color_brewer(palette = "Set1") +
  labs(title = " Oleic vs Eicosenoic  colored by Region (categorical)",
       x = "Eicosenoic",
       y = "Oleic") +
  theme_minimal()
#Discrete color coding relies primarily on preattentive mechanisms, so I can quickly discern boundaries.

# step4
ggplot(data, aes(x=eicosenoic, y=oleic)) +
  geom_point(aes(color =cut_interval(linoleic,3), shape = cut_interval(palmitic,3), size = cut_interval(palmitoleic,3)),
             alpha = 0.8, stroke = 0.3) +
  scale_color_brewer(palette = "Set1") +             
  scale_shape_manual(values = c(16, 17, 15)) +        
  scale_size_manual(values = c(2.2, 3.2, 4.2)) +      
  labs(title = "Oleic vs Eicosenoic with 3×3×3 encodings",
       color = "Linoleic (3)", shape = "Palmitic (3)", size = "Palmitoleic (3)",
       x = "eicosenoic", y = "oleic") +
  theme_minimal()
# Extremely difficult. 
# When multiple channels are jointly encoded, it is no longer parallel processing of pre-attention, but requires serial comparison of attention.
# Combining metrics does not sum up the capacity. So the working memory load is high, making it difficult to distinguish 27 combinations quickly and stably.

# step5
ggplot(data, aes(x=eicosenoic, y=oleic)) +
  geom_point(aes(color =as.factor(Region), shape = cut_interval(palmitic,3), size = cut_interval(palmitoleic,3)),
             alpha = 0.8, stroke = 0.3) +
  scale_color_brewer(palette = "Set1") +             
  scale_shape_manual(values = c(16, 17, 15)) +        
  scale_size_manual(values = c(2.2, 3.2, 4.2)) +      
  labs(title = "Oleic vs Eicosenoic with 3×3×3 encodings",
       color = "Region (3)", shape = "Palmitic (3)", size = "Palmitoleic (3)",
       x = "eicosenoic", y = "oleic") +
  theme_minimal()
# Boundary between two groups of elements with the same visual feature is detected preattentively.

# step6
area_counts <- data %>%
  count(Area, name = "n") %>%
  arrange(desc(n)) %>%
  mutate(pct = n / sum(n))

plot_ly(
  data = area_counts,
  labels = ~Area,
  values = ~n,
  type = "pie",
  textinfo = "none",                
  hovertemplate = paste(
    "<b>%{label}</b><br>",
    "Count: %{value}<br>",
    "Share: %{percent}",
    "<extra></extra>"
  )
 ) %>%
  layout(title = "Proportions of oils by Area ",
         showlegend = TRUE)

#The pie chart demonstrates the perceptual limits of judging angles/areas and the cost of hover-only labels, which force attentive, serial inspection rather than rapid, preattentive comparison.

p_scatter <- ggplot(data, aes(x = eicosenoic, y = linoleic)) +
  geom_point() +
  labs(title = "Scatter: Linoleic vs Eicosenoic",
       x = "Eicosenoic", y = "Linoleic") +
  theme_minimal()
p_scatter

p_contour <- ggplot(data, aes(x = eicosenoic, y = linoleic)) +
  stat_density_2d() +     
  scale_color_viridis_d() +
  labs(title = "2D-density contour plot : Linoleic vs Eicosenoic",
       x = "Eicosenoic", y = "Linoleic", color = "ndensity level") +
  theme_minimal()
p_contour

#
