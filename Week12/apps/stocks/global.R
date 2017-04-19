library(jsonlite)
library(shiny)
library(dcr)
library(dplyr)
library(lubridate)
library(quantmod)

stocks <- stockSymbols()[-1, ]
value <- stocks$Symbol
names(value) <- with(stocks, paste0("(", Symbol, ")", Name))
index <- c("NASDAQ-100" = "^NDX", "NASDAQ Composite" = "^IXIC", "S&P 500" = "^GSPC", "NYSE COMPOSITE" = "^NYA", 
           "Dow Jones Industrial Average" = "^DJI")
names(index) <- paste0("(", index, ")", names(index))
comb_name <- list(Index = names(index), Stock = names(value))
comb <- c(value, index)