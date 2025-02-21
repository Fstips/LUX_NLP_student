#' Title: Retailers Revised
#' Purpose: Build a tag cloud Experimental
#' Author: Ted Kwartler
#' email: edward.kwartler@hult.edu
#' License: GPL>=3
#' Date: Dec 28 2020
#'


# libs
library(ggplot2)
library(tm)
library(dplyr)

# Set wd
setwd("~/Desktop/hult_NLP_student/lessons/class3/data")

# Options & Functions
options(stringsAsFactors = FALSE, scipen = 999)
Sys.setlocale('LC_ALL','C')

tryTolower <- function(x){
  y = NA
  try_error = tryCatch(tolower(x), error = function(e) e)
  if (!inherits(try_error, 'error'))
    y = tolower(x)
  return(y)
}

cleanCorpus<-function(corpus, customStopwords){
  corpus <- tm_map(corpus, content_transformer(qdapRegex::rm_url))
  #corpus <- tm_map(corpus, content_transformer(replace_contraction)) 
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, content_transformer(tryTolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  return(corpus)
}

# Create custom stop words
stops <- c(stopwords('english'), 'carrefour', 'tesco')

# Bring in the two corpora; works with no meta data
retailers <- Corpus(DirSource("polarizedCloud/"))

# Get word counts
# mind the order is the same as is list.files('~/Desktop/hult_NLP_student/lessons/class3/data/polarizedCloud')
carreCount <- length(unlist(strsplit(content(retailers[[1]]), " ")))
tescoCount <- length(unlist(strsplit(content(retailers[[2]]), " ")))

# Clean & TDM
cleanRetail <- cleanCorpus(retailers, stops)
cleanRetail <- TermDocumentMatrix(cleanRetail)

# Create data frame from TDM
retailDF <- as.data.frame(as.matrix(cleanRetail))
head(retailDF)

# subset and calc diff
retailDF      <- subset(retailDF, retailDF[,1]>0 & retailDF[,2]>0) #in case stops make empty docs
retailDF$diff <- retailDF[,1]-retailDF[,2]

# Words used more by Carrefour
carrefourDF <- subset(retailDF, diff > 0) # Said more  by carre
# Words used more by Tesco
tescoDF     <- subset(retailDF, diff < 0) # Said more by tesco

# Calc how the much the term contributes to the specific corpus 
carrefourDF$density <- carrefourDF$carrefour.csv/carreCount
tescoDF$density     <- tescoDF$carrefour.csv/tescoCount

### Step 3: Create visualization
topNum <- 20
obama.df <- head(carrefourDF[order(carrefourDF$diff, decreasing = T),],topNum)
palin.df <- head(tescoDF[order(abs(tescoDF$diff), decreasing = T),],topNum)

ggplot(obama.df, aes(x=diff, y=density))+
  geom_text(aes(#size=obama.df[,1], 
                label=row.names(obama.df), colour=diff),
            hjust = "inward", vjust = "inward")+
  geom_text(data=palin.df, 
            aes(x=diff, y=density, label=row.names(palin.df), 
                #size=palin.df[,1],
                color=diff),
            hjust = "inward", vjust = "inward")+
  scale_size(range=c(3,11), name="Word Frequency")+scale_colour_gradient(low="darkred", high="darkblue", guide="none")+
  scale_x_continuous(breaks=c(min(palin.df$diff),0,max(obama.df$diff)),labels=c("Said More about Tesco","Said Equally","Said More about Carrefour"))+
  scale_y_continuous(breaks=c(0),labels=c(""))+xlab("")+ylab("")+theme_bw()
# End