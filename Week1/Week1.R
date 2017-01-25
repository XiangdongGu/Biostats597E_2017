# Week 1 - Introduction to SQL

#--------------------------------------------------------------------
# Be familiar with Environment
#--------------------------------------------------------------------

# If you have not installed RQLite then install it
install.packages("RSQlite")

library(RSQLite)

# Connect to the SQLite database (the sqlite file)
con <- dbConnect(RSQLite:::SQLite(), "../data/examples.sqlite")

# What tables are available in the database
dbListTables(con)

# What fields are available in the table countries
dbListFields(con, "countries")

# send query get all data from the table continents
dbGetQuery(con, "select * from continents")

# Disconnect with the database once your work is down
dbDisconnect(con)
