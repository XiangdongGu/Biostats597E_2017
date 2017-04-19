library(shiny)
library(quantmod)

# Get All Stocks
#stock_data <- stockSymbols()
#save(stock_data, file = "stock_data.rda")
load("stock_data.rda")
stock_names <- stock_data$Name
stock_ticket <- stock_data$Symbol

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Stock Plot"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      # Select the stock
      selectInput("stock", "Select Stock", stock_names,
                  selected = "Microsoft Corporation"),
      
      # Select date range to plot
      dateRangeInput("dates", "Date Range", 
                     start = as.Date("2010-01-01"),
                     end = Sys.Date()),
      
      # Select chart type
      selectInput("type", "Select Chart Type",
                   c("auto", "candlesticks", "matchsticks", "bars","line"))
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
       plotOutput("stockPlot")
    )
  )
))
