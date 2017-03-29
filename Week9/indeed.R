library(httr)
library(jsonlite)
library(rvest)

#------------------------------------------------------------------------------
# USING INDEED.COM API TO OBTAIN JOB DATA
#------------------------------------------------------------------------------

# Frist go to indeed.com to create publisher account and obtain publisher id
publisher_id <- "4892433118027808"

# Generate a query
res <- GET("http://api.indeed.com/ads/apisearch",
           query = list(publisher = publisher_id,   # put your publisher id
                        v = 2,                      # version number, set it to 2
                        format = "json",            # returned result format
                        q = "data scientist",       # search string
                        l = "boston, ma",           # location
                        start = 0))                 # page number, each page 10 results

# Extract content part of the reponse
content <- fromJSON(content(res, "text"))

# Check information of the results
names(content)

# How many total results (we only return 10 results per query)
# If we want to see more, we can set start to a different number, start = 2, 3, ...
content$totalResults

# What is returned search results
result <- content$results

# We can further scrape the detailed job description for each job post (e.g. first one)
# Then we extract the job summary part of the post
job_sum <- read_html(result$url[5]) %>% 
  html_nodes("#job_summary") %>% 
  html_text()

cat(job_sum)

# WRAP THE STEPS INTO FUNCTIONS------------------------------------------------
# Function to search job and return result as data frame
jobsearch <- function(...) {
  # Make query
  q <- c(list(publisher = publisher_id,
              v = 2,
              format = "json"),
         list(...))
  res <- GET("http://api.indeed.com/ads/apisearch", query = q)
  jsonlite::fromJSON(content(res, "text"))$results
}

# extract 10 jobs a time
jobsearch(q = "data scientist", l = "boston, ma", start = 0)
jobsearch(q = "data scientist", l = "boston, ma", start = 1)

# extract 100 results a time
ds_job <- do.call("rbind", 
                  lapply(0:29, function(x)
                    jobsearch(q = "data scientist", 
                              l = "boston, ma", 
                              start = x)))


# Function to extract job summary for a given url
job_summary <- function(url) {
  read_html(url) %>% 
    html_nodes("#job_summary") %>% 
    html_text()
}

job_summary(result$url[6]) %>% cat()

# Example, what is most needed data scientist skills?--------------------------
# get all job summaries for ds job
jobsums <- sapply(ds_job$url, job_summary)

# Function to find proportion of jobs needing a specific skiils
p_need <- function(skill, text) {
  pattern <- sprintf("\\<%s\\>", skill) # remeber what \> and \< mean?
  mean(grepl(pattern, text, ignore.case = TRUE))
}

skills <- c(".+sql", "python", "sas", "matlab", "R", "hadoop", "spark")
prob_needs <- sapply(skills, p_need, text = jobsums)

data.frame(skills, prob_needs, row.names = NULL)

# Can you find out what skiils needed to become a statistician?
sum_skills <- function(jobsums) {
  data.frame(skills,
             prob_needs = sapply(skills, p_need, text = jobsums),
             row.names = NULL)
}

# make the process a pipeline
do.call("rbind", 
        lapply(0:19, function(x)
          jobsearch(q = "statistician", 
                    l = "boston, ma", 
                    start = x))) %>%
  "[["("url") %>%
  sapply(job_summary) %>%
  sum_skills()

