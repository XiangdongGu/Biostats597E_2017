library(data.table)
library(shiny)
library(quantmod)

load("stock_data.rda")
stock_names <- stock_data$Name
stock_ticket <- stock_data$Symbol

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  output$stockPlot <- renderPlot({
    #if (is.null(input$ticket)) return(NULL)
    
    # input stock ticket
    ticket <- stock_ticket[stock_names == input$stock]
    
    # input date range
    date_sub <- paste0(input$dates, collapse = "/")

    # get the stocks from YAHOO
    getSymbols(ticket)
    data <- get(ticket)
    
    # make the plot using chosen parameters
    chartSeries(data, type = input$type, subset = date_sub, theme = chartTheme("white"))
  })
   
})
