

shinyUI(fixedPage(
  fixedRow(column(2, radioButtons("index", "", c("Index", "Stock")), selected = "Index"),
           column(8, selectInput("stock", "", names(index))), width = "100%"),
  br(),
  fixedRow(column(2.8, div(strong("Days by Gain/Loss"), dc_reset("chart_gainloss"), id = "chart_gainloss")),
           column(2.8, div(strong("Quarters"), dc_reset("chart_quarter"), id = "chart_quarter")),
           column(2.8, div(strong("Day of Week"), dc_reset("chart_weekday"), id = "chart_weekday")),
           column(3.6, div(strong("Days by Fluctuation(%)"), dc_reset("chart_fluctuation"), id = "chart_fluctuation")),
   fixedRow(column(12, div(strong("Monthly Index Abs Move & Volume/500,000 Chart"), dc_reset("chart_volume"), id = "chart_move"))),
   fixedRow(column(12, div(id = "chart_volume")))
    ),
  chartOutput("mydc")
))
