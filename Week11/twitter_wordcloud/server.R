library(shiny)
library(ggplot2)
library(tm)
library(twitteR)
library(wordcloud)
library(SnowballC)

# Twitter Setup
consumer_key <- "RGl8yI0sksD6HdZoFi27hbK3Z"
consumer_secret <- "6qsA05Rs8GwOw5H87q3fiX1k7WcyMerBC7cYpbNcVpyW8Ssr9i"
access_token <- "960801247-49pv4uSRitU72I4T32Ft7jqkZyPHsj8c894bGcaa"
access_secret <- "P8QgD3Uxb5S0cmp5hE37sdApPHPYmSqoEdBvENkZ1k0DX"
options(httr_oauth_cache=T)
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

mywordcloud <- function(text, n) {
  tt <- searchTwitter(text, n)
  tt <- sapply(tt, function(x) x$text)
  tt <- iconv(tt, "UTF-8", "ASCII", sub="")
  # Use tm to clean up texts
  tt <- Corpus(VectorSource(tt))
  tt <- tm_map(tt, PlainTextDocument)
  # remove punctuation
  tt <- tm_map(tt, removePunctuation)
  ## remove stop words like me my
  tt <- tm_map(tt, removeWords, stopwords('english'))
  tt <- tm_map(tt, content_transformer(tolower))
  tt <- tm_map(tt, removeWords, tolower(text))
  ## words stemming (walking -> walk)
  #tt <- tm_map(tt, stemDocument)
  # word cloud plot
  wordcloud(tt, min.freq = 3, max.words = 100,
            colors=brewer.pal(8, "Dark2"))   
}

shinyServer(function(input, output) {
   
  output$wordcloud <- renderPlot({
    mywordcloud(input$search, input$numtweets)
  })
  
})
