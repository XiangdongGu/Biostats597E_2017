library(dcr)
library(shiny)

shinyUI(fixedPage(

  titlePanel("Example for Input Binding"),
  
  fixedRow(column(4, dc_ui("chart1", "cyl", show_filter = TRUE)),
           column(4, dc_ui("chart2", "mpg", show_filter = TRUE)),
           column(4, dc_ui("chart3", "carb", show_filter = TRUE))),

  chartOutput("dcr_out"),
  
  hr(),
  h4("The data table will filter the data based on dc charts filters"),
  dataTableOutput("filtered_data")

))
