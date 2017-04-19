library(shiny)
library(dplyr)

shinyServer(function(input, output, session) {
  
  output$dcr_out <- renderChart_csv(session, {
    mydcr <- dcr(mtcars)
    chart1 <- dcrchart("pieChart", "chart1", "cyl", reduceCount(), width = 300, height = 250, radius = 100)
    
    chart2 <- dcrchart("lineChart", "chart2", "mpg", reduceMean("wt"), width = 300, height = 250,
                       xAxisLabel = "Gear", yAxisLabel = "Average Weight")
    
    
    chart3 <- dcrchart("rowChart", "chart3", "carb", reduceCount(), width = 300, height = 250)
    
    mydcr + chart1 + chart2 + chart3
  }, input_binding = TRUE)

  
  output$filtered_data <- renderDataTable({
    data <- mtcars
    # We use input$chart_id to access filter values
    f_cyl <- input$chart1
    f_mpg <- input$chart2
    f_carb <- input$chart3
    # If there is no filters on the chart, the input returns NULL
    if (!is.null(f_cyl)) data <- filter(data, cyl %in% f_cyl)
    if (!is.null(f_mpg)) data <- filter(data, between(mpg, f_mpg[1], f_mpg[2]))
    if (!is.null(f_carb)) data <- filter(data, carb %in% f_carb)
    data
  })
  

})
