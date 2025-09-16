library(dplyr)
library(tidytext)
library(wordcloud)
library(textdata)
library(ggraph)
library(igraph)
library(tidyr)
library(stringr)
library(RColorBrewer)
library(visNetwork)

data <- read.csv("tweets.csv")

data("stop_words")

data_clean <- data %>%
  mutate(label = ifelse(label == 0, "Fake", "True")) %>%
  unnest_tokens(word, tweet) %>%
  anti_join(stop_words, by = "word")

word_counts <- data_clean %>%
  count(label, word, sort = TRUE)

par(mfrow=c(1,2))

fake_words <- subset(word_counts, label == "Fake")
wordcloud(words = fake_words$word, 
          freq = fake_words$n,
          max.words = 100)
title("Fake News Word Cloud")

true_words <- subset(word_counts, label == "True")
wordcloud(words = true_words$word, 
          freq = true_words$n,
          max.words = 100)
title("Ture News Word Cloud")

#step2
afinn <- get_sentiments("afinn")

tweets_sent <- data %>%
  mutate(chunk = rep(1:ceiling(n()/5), each = 5, length.out = n())) %>%  
  unnest_tokens(word, tweet) %>%
  inner_join(afinn, by = "word") %>%
  group_by(label, chunk) %>%
  summarise(sentiment = mean(value), .groups = "drop") 


ggplot(tweets_sent, aes(x = chunk, y = sentiment, fill = factor(label))) +
  geom_col(position = "dodge") +
  labs(title = "Sentiment per Chunk (Fake vs Real News)",
       x = "Chunk Index (every 5 lines)",
       y = "Average Sentiment",
       fill = "News Type") +
  theme_minimal()


#step3


make_phrase_net_vis <- function(data, connectors, news_type, min_freq = 1) {
  
  df <-data[data$label==news_type,]
  
  tidy_frame <- df %>%
    unnest_tokens(trigram, tweet, token = "ngrams", n = 3) %>%
    separate(trigram, into = c("word1", "word2", "word3"), sep = " ") %>%
    filter(word2 %in% connectors)
  
  tidy_frame <- tidy_frame %>%
    filter(!word1 %in% stop_words$word)%>%
    filter(!word3 %in% stop_words$word)
  
  
  edges <- tidy_frame %>%
    count(word1, word3, name = "width", sort = TRUE) %>%
    filter(width >= min_freq) %>%
    transmute(from = word1, to = word3, width, arrows = "to")
  
  right_words <- edges %>% count(word = to,   wt = width)
  left_words  <- edges %>% count(word = from, wt = width)
  
  nodes <- full_join(left_words, right_words, by = "word") %>%
    mutate(n.x = coalesce(n.x, 0),        
           n.y = coalesce(n.y, 0),        
           n.total = n.x + n.y,
           id = word, label = word, value = n.total) %>%
    filter(n.total >= 3)
  
  rnk <- rank(nodes$n.total, ties.method = "min", na.last = "keep")
  denom <- max(rnk, na.rm = TRUE); if (!is.finite(denom)) denom <- 1
  grp <- ifelse(is.na(rnk), 1L, pmax(1L, ceiling(rnk / denom * 9)))
  
  nodes$color <- brewer.pal(9, "Blues")[grp]
  nodes$`font.size` <- 25L
  
  nodes <- nodes %>% filter(id %in% edges$from | id %in% edges$to)
  
  visNetwork(nodes, edges) 
}

connectors <- c("am", "is", "are", "was", "were")

make_phrase_net_vis(data, connectors, 0,  min_freq = 2)

make_phrase_net_vis(data, connectors, 1,  min_freq = 2)

