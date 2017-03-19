#-----------------------------------------------------------------------------#
# SPARKLYR EXAMPLE ANALYZING AMERICAN COMMUNITY SURVEY DATA
#-----------------------------------------------------------------------------#
library(dplyr)
library(sparklyr)

# Create Spark Connection------------------------------------------------------
# Since data is large, we need to configure Spark to have larger memory
# Usually we crete config.yml file to specify configuration in same folder
# We can open SparkUI to see the configuration and job process

sc <- spark_connect("local", config = spark_config())

# Read data--------------------------------------------------------------------
# Two population files ss13pusa.csv and ss13pusb.csv
# We can specify multiple files to read

infile <- "2013-american-community-survey/pums/ss13pus*.csv"

# Read the files to Spark------#
# infer_schema: infer_schema takes extra time to have extra pass of the data
#               we can set it FALSE so all variables are read as character
#               the we can do manual conversion of the variabls of interest,
#               this is good when there are a lot of features but only few
#               of them will be used
# memory: if memory is TRUE, it will read all data into memory and cache there
#         this is not good when only few of the many variables will be of 
#         interest, instead we should process it and pick those variables of
#         interest then persist in memory, otherwise we may not have sufficient
#         memory to hold the orignal data in the first place
#
acs_tbl <- spark_read_csv(sc, "acs", infile, infer_schema = FALSE,
                          repartition = 100, memory = FALSE)

# Extract only intersted variables, cache to memory then do analysis---#
# PUMA: similar to zip code
# ST: State code (25 is MA)
# AGEP: age
# PINCP: Total person's income
# SCHL: education level (21 bachelor, 24 is doctorate)
# PWGTP: the weight of the record
#
# sdf_register: register the data into Spark SQL
# tbl_cache: cache the Spark SQL data into memory
#
acs_tbl <- acs_tbl %>%
  select(PUMA, ST, AGEP, PINCP, SCHL, PWGTP) %>%
  sdf_register("acs")

tbl_cache(sc, "acs")

# Read State Code to R-------#
state <- read.csv("state_code.txt", header = FALSE, stringsAsFactors = FALSE,
                  colClasses = rep("character", 2))
names(state) <- c("ST", "State")
state$State <- gsub(" +$", "", state$State)

# convert to numeric
acs_tbl <- acs_tbl %>%
  mutate(AGEP = as.numeric(AGEP),
         PINCP = as.numeric(PINCP),
         PWGTP = as.numeric(PWGTP))

# By state obtain average Age, percent of Doctor degrees and sort
# When data is summarised, the size is small and we can collect to R
state_sum <- acs_tbl %>%
  mutate(doctor = as.numeric(SCHL == "24")) %>%
  group_by(ST) %>%
  summarise(age = sum(AGEP * PWGTP) / sum(PWGTP),
            doctor = sum(doctor * PWGTP) / sum(PWGTP)) %>%
  collect() %>%
  inner_join(state)

View(state_sum)

# Is advanced degree associated with high income?
degree_sum <- acs_tbl %>%
  mutate(education = ifelse(SCHL == "24", "Doctor",
                            ifelse(SCHL %in% c("22", "23"), "Master",
                                   ifelse(SCHL == "21", "Bachelor",
                                          "Other")))) %>%
  group_by(education) %>%
  summarise(income = sum(PINCP * PWGTP) / sum(PWGTP),
            age = sum(AGEP * PWGTP) / sum(PWGTP)) %>%
  collect()
         
View(degree_sum)

library(ggplot2)
ggplot(degree_sum, aes(education, income)) +
  geom_bar(fill = "steelblue", stat = "identity") +
  scale_y_continuous(labels = scales::dollar) +
  theme_bw() 
         