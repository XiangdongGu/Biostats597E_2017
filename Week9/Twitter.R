# install.packages("twitteR")
# Set up twitter authentication------------------------------------------------
library(twitteR)
consumer_key <- "*****************"
consumer_secret <- "*****************"
access_token <- "*****************"
access_secret <- "*****************"

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

# Web request------------------------------------------------------------------
# Check rate limit and usage for different APIs
getCurRateLimitInfo()

# Search with a given string
umass <- searchTwitter("Umass Amherst", 10)

# Metioning twitter account UmassAmherst
umass1 <- searchTwitter("@UmassAmherst")

# Sent from twitter account UmassAmherst
umass2 <- searchTwitter("from:UmassAmherst", n = 10)

# For more search string specification: https://dev.twitter.com/rest/public/search

# Get a specific user information----------------------------------------------
# more details: ?user
um <- getUser("UmassAmherst")
um$name
um$lastStatus
um$description
um$friendsCount
um$location
um$getFollowers(n = 10)
um$getFriends()
