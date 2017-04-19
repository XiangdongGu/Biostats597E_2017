
library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Twitter Word Cloud"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
       fluidRow(column(6, textInput("search", "Input search string")),
                column(6, numericInput("numtweets", "Number of tweets", 100, 1, 1000))),
       submitButton("Submit")
    ),
    
    mainPanel(
       plotOutput("wordcloud")
    )
  )
))
