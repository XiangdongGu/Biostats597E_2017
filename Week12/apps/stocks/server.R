
shinyServer(function(input, output, session) {
  observe({
    x <- comb_name[[input$index]]
    updateSelectInput(session, "stock", choices = x)
  })
  data <- reactive({
    stock <- input$stock
    data <- try(getSymbols(comb[stock], src = "yahoo",  auto.assign = FALSE, from = as.Date("1990-1-1")))
    if (inherits(data, "try-error")) return(NULL)
    data <- data.frame(data)
    names(data) <- c("open", "high", "low", "close", "volume", "adjusted")
    data <- data.frame(date = as.Date(row.names(data), "%Y-%m-%d"), data)
    data <- mutate(data,
                   date = as.Date(date, "%m/%d/%Y"),
                   gainloss = ifelse(open > close, 'Loss', 'Gain'),
                   quarter = paste0("Q", quarter(date)),
                   dayofweek = factor(weekdays(date, TRUE), levels = c("Mon", "Tue", "Wed", "Thu", "Fri")),
                   fluctuation = abs(close - open),
                   pfluctuation = round((close - open)/open*100),
                   indexavg = (open + close)/2,
                   month = ceiling_date(date, "month"),
                   year = year(date)) %>%
      select(volume, gainloss:month)
    data
  })
  
  output$mydc <- renderChart({
    data <- data()
    if (is.null(data)) return(dcr(data.frame(x = 1)))
    mydcr <- dcr(data)
    gainloss <- dcrchart("pieChart", "chart_gainloss",  "gainloss", reduceCount(), 180, 180, radius = 80)
    
    quarter <- dcrchart("pieChart", "chart_quarter", "quarter", reduceSum("volume"), 180, 180, radius = 80, innerRadius = 30)
    
    weekday <- dcrchart("rowChart", "chart_weekday", "dayofweek", reduceCount(), 180, 180, 
                        margins = list(top = 20, left = 10, right = 10, bottom = 20),
                        ordinalColors = c('#3182bd', '#6baed6', '#9ecae1', '#c6dbef', '#dadaeb'),
                        title = simple_fun("d.value"), elasticX = TRUE, xAxis = x_axis(ticks = 4))
    
    fluctuation <- dcrchart("barChart", "chart_fluctuation", "pfluctuation", reduceCount(), 420, 180,
                            margins = list(top = 10, right = 50, bottom = 30, left = 40),
                            centerBar = TRUE, gap = 1, round = dc_code("dc.round.floor"), 
                            alwaysUseRounding = TRUE, renderHorizontalGridLines = TRUE, elasticY = TRUE,
                            xAxis = x_axis(tickFormat = simple_fun("d + '%'")),
                            yAxis = y_axis(ticks = 5))
    
    movechart <- dcrchart("lineChart", "chart_move", "month", reduceMean("indexavg"), 990, 200, 
                          margins = list(top = 30, right = 50, bottom = 25, left = 40),
                          renderArea = TRUE, mouseZoomable = TRUE, round = dc_code("d3.time.month.round"),
                          xUnits = dc_code("d3.time.months"), elasticY = TRUE, renderHorizontalGridLines = TRUE,
                          brushOn = FALSE, legend = dc_legend(x = 800, y = 10, itemHeight = 13, gap = 5),
                          yAxis = y_axis(ticks = 8),
                          stack = dc_stack(reduceSum("fluctuation"), 'Monthly Index Move', simple_fun("d.value")),
                          group_name = 'Monthly Index Average', rangeChart = chartname("chart_volume"))
    
    volumechart <- dcrchart("barChart", "chart_volume", use_dimension("chart_move"), reduceSum("volume/500000"), 990, 40,
                            margins = list(top = 0, right = 50, bottom = 20, left = 40),
                            centerBar = TRUE, gap = 1, round = dc_code("d3.time.month.round"),
                            alwaysUseRounding = TRUE, xUnits = dc_code("d3.time.months"), yAxis = y_axis(ticks = 0, tickSize = 0))
    
    mydcr +  gainloss + quarter + weekday + fluctuation + movechart + volumechart
  })
 
})


