#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Mar 27 13:07:47 2022

@author: user
"""

import tweepy
import pandas as pd

#client = tweepy.Client(bearer_token="AAAAAAAAAAAAAAAAAAAAABWraAEAAAAA6marFuzvTRXO6d%2FSulUPQ05GacE%3DStwDUcHjO4WOlYik26K6WweS6S9GelrwMfXaN5H7Nn5Stfn0J1")


client = tweepy.Client(bearer_token= 'AAAAAAAAAAAAAAAAAAAAALRkaQEAAAAA989GenO8QF9h9yCLf%2Brw9882rQA%3DzwzX620NkZZfvdE0N0I0yzEIDWVdRISuZSLx48MER6hY66HlnL')


# Replace with your own search query
query = 'unemployment lang:en place_country:US'
query = 'unemployment lang:en'


# Name and path of the file where you want the Tweets written to
#file_name = 'tweets_text.txt'
olddate = None
currdate = None

df = []
df_time = []
df_id = []

start_time = '2020-01-01T00:00:00Z'
end_time = '2020-01-31T00:00:00Z'

# https://docs.tweepy.org/en/stable/client.html#tweepy.Client.search_all_tweets
#with open(file_name, 'a+') as filehandle:
for tweet in tweepy.Paginator(client.search_all_tweets, query=query, start_time=start_time, end_time=end_time,
                              tweet_fields=['context_annotations', 'created_at'], max_results=100).flatten(limit=500):
                                
    #break

    currdate = str(tweet.created_at.year) + "_" + str(tweet.created_at.month) + '_' + str(tweet.created_at.day)
    
    
    if currdate != olddate:        
        if len(df)>0:
            
            dfnew = pd.DataFrame([df_id, df_time, df]).T
            dfnew.columns = ['id','created_time','text']
            date = str(tweet.created_at.year) + "_" + str(tweet.created_at.month) + '_' + str(tweet.created_at.day)
            dfnew.to_csv("tweet" + date + ".csv")
            
            print("exporting tweet on", currdate)
                  