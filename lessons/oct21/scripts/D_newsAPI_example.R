#' Title: News API
#' Purpose: Get data from JSON
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Oct 20, 2021
#'

# Libraries
library(jsonlite)
library(pbapply)

# Options
options(stringsAsFactors = F)

# www.newsapi.org Key
#apiKey <- readLines('~/Desktop/GSERM_Text_Remote_admin/newsAPI.txt')
#apiKey <- 'XXXXXXXXXXXXXXXXXXXXXXX'

# Top headlines in the US endpoint:
usURL <- paste0('https://newsapi.org/v2/top-headlines?country=us&apiKey=', apiKey)
usURL

# Endpoint for all news sources
#https://newsapi.org/v2/sources?apiKey=####################

# Get last weeks information
to   <- Sys.Date()
from <- to-7

# Let's get Al Jazeera Top Headlines
apiURL <- paste0('https://newsapi.org/v2/top-headlines?sources=',
                'al-jazeera-english', # get from the sources endpoint
                '&from=', from,
                '&',
                'to=', to,
                '1&sortBy=popularity&apiKey=',
                apiKey)
apiURL

# Let's get the text
newsInfo <- fromJSON(apiURL)

# Organize the API response and save
newsInfo$status           <- NULL
newsInfo$totalResults     <- NULL
newsInfo$articles$source  <- NULL

finalContent <- newsInfo[[1]]
finalContent
#write.csv(finalContent, 'finalNewsContent.csv', row.names = F)

# 
source <- 'wsj.com'
allArticles <- fromJSON(paste0('https://newsapi.org/v2/everything?domains=',
                        source,
                        '&apiKey=b6d9f96c78b34ee98bd84a23d3f74bfb'))

allArticles$status
allArticles$totalResults
allArticles$articles[1,]
# End
