# Importing packages
library(ggplot2)
library(plotly)
library(tidyverse)
library(zoo)
library(dplyr)
library(lubridate)
library(devtools)
library(leaflet)
library(readr)
library(rgdal)
library(tmap)
library(ggmap)
library(RColorBrewer)
library(tm)
library(wordcloud)
library(tidytext)
library(wesanderson)
library(textdata)
library(reshape2)
library(graphics)
library(stopwords)
library(stringr)
library(shiny)

# Data Pre-processing protocols

##### Wenyi's work: Weekly wage and working hours plots-------------------------
# Importing datasets
weekly_wage <- read.csv("./avg_weekly_wage_hours/wage4.csv")
weekly_hours <- read.csv("./avg_weekly_wage_hours/hours4.csv")

#####---------------------------------------------------------------------------

##### Nicole's work: Unemployment rates (national, industrial and stage averages)
## Importing datasets

total <- read.csv("unemployment/SeriesReport-20220423235636_21d8c2.csv", 
                  stringsAsFactors = FALSE,
                  fileEncoding="UTF-8-BOM")
states <- read.csv("unemployment/unemployment by states.csv", 
                   stringsAsFactors = FALSE,
                   fileEncoding="UTF-8-BOM")
industry <- read.csv("unemployment/Unempolyment rate by industry.csv", 
                     stringsAsFactors = FALSE,
                     fileEncoding="UTF-8-BOM")

# Pre-processing steps for leaflet map
colnames(states)[2] <- 'Rate_2019'
colnames(states)[3] <- 'Rate_2020'
colnames(states)[4] <- 'Rate_2021'

geom <- read.csv("unemployment/statelatlong.csv")

colnames(geom)[4] <- 'State'

geom <- subset(geom, select = -c(1))

statesgeom <- states %>%
  left_join(geom, by = 'State')

# Setting the labels
content3 <- paste("unemployment Rate:",statesgeom$Rate_2019,"<br/>",
                  "State:",statesgeom$State,"<br/>")

content4 <- paste("unemployment Rate:",statesgeom$Rate_2020,"<br/>",
                  "State",statesgeom$State,"<br/>")

content5 <- paste("unemployment Rate:",statesgeom$Rate_2021,"<br/>",
                  "State",statesgeom$State,"<br/>")


##### Shauna's work: # Twitter Text Mining and Sentiment Analysis---------------
# Importing and cleaning data
df <- read_csv("twitter_api_text_analysis/unemployment_tweets_2019.csv")
df2 <- read_csv("twitter_api_text_analysis/unemployment_tweets_2020.csv")
df3 <- read_csv("twitter_api_text_analysis/unemployment_tweets_2021.csv")

unemployment <- df %>%
  select(id, text) 

colnames(unemployment)[1] <- "doc_id"
colnames(unemployment)[2] <- "text"
unemployment_for_corpus <- unemployment %>%
  select(doc_id, text)

df_source <- DataframeSource(unemployment_for_corpus)


unemployment2 <- df2 %>%
  select(id, text) 

colnames(unemployment2)[1] <- "doc_id"
colnames(unemployment2)[2] <- "text"
unemployment_for_corpus2 <- unemployment2 %>%
  select(doc_id, text)

df_source2 <- DataframeSource(unemployment_for_corpus2)


unemployment3 <- df3 %>%
  select(id, text) 

colnames(unemployment3)[1] <- "doc_id"
colnames(unemployment3)[2] <- "text"
unemployment_for_corpus3 <- unemployment3 %>%
  select(doc_id, text)

df_source3 <- DataframeSource(unemployment_for_corpus3)

# Making tweet corpora
df_corpus_unemployment <- VCorpus(df_source)

df_corpus_unemployment2 <- VCorpus(df_source2)

df_corpus_unemployment3 <- VCorpus(df_source3)

# Text cleaning, removing certain words
clean_corpus <- function(corpus){
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeWords, c(stopwords("en")))
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus,removeWords, c("unemployment",  "get", "amp", 
                                         "people", "also", "potus", 
                                         "realdonaldtrump"))
  return(corpus)
}

df_clean <- clean_corpus(df_corpus_unemployment)

df_clean2 <- clean_corpus(df_corpus_unemployment2)

df_clean3 <- clean_corpus(df_corpus_unemployment3)


# Text Mining
unemployment_tdm <- TermDocumentMatrix(df_clean)

matrix <- as.matrix(unemployment_tdm)

words <- sort(rowSums(matrix),decreasing=TRUE) 
final_df <- data.frame(word = names(words),freq=words) %>%  
  filter(word!="jobs") %>% filter(word!="benefits") %>%  
  filter(word!="realdonaldtrump") %>% 
  filter(word!="covid")

unemployment_tdm2 <- TermDocumentMatrix(df_clean2)

matrix2 <- as.matrix(unemployment_tdm2)

words2 <- sort(rowSums(matrix2),decreasing=TRUE) 
final_df2 <- data.frame(word2 = names(words2),freq2=words2) %>%  
  filter(word2!="jobs") %>% 
  filter(word2!="benefits") %>%  
  filter(word2!="realdonaldtrump")


unemployment_tdm3 <- TermDocumentMatrix(df_clean3)

matrix3 <- as.matrix(unemployment_tdm3)

words3 <- sort(rowSums(matrix3),decreasing=TRUE) 
final_df3 <- data.frame(word3 = names(words3),freq3=words3) %>%  
  filter(word3!="jobs") %>% filter(word3!="benefits") %>%  
  filter(word3!="realdonaldtrump")

# For sentiment analyses
cleaned_twt<-df%>%
  select(text)%>%
  unnest_tokens(word, text)%>%
  anti_join(stop_words)

cleaned_twt2<-df2%>%
  select(text)%>%
  unnest_tokens(word, text)%>%
  anti_join(stop_words)

cleaned_twt3<-df3%>%
  select(text)%>%
  unnest_tokens(word, text)%>%
  anti_join(stop_words)

##### Toby's work: Movement range maps------------------------------------------

## Importing usa dataframe weekly average for state and county
usa_weekly_avg_county <- read.csv("./movement_range_maps/movement_range_data_usa_2020_county.txt",
                                  sep = ",")
usa_weekly_avg_state <- read.csv("./movement_range_maps/movement_range_data_usa_2020_state.txt",
                                 sep = ",")


## Importing shape for state and county

county_shp <- readOGR("./movement_range_maps/cb_2021_us_county_500k/cb_2021_us_county_500k.shp",
                      verbose = FALSE)
state_shp <- readOGR("./movement_range_maps/cb_2021_us_state_500k/cb_2021_us_state_500k.shp",
                     verbose = FALSE)

## defining the color palette
choro_pal <- colorBin("YlOrRd", domain = usa_weekly_avg_county$avg_stay_put,
                      bins = c(0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.5, 0.7, 1))