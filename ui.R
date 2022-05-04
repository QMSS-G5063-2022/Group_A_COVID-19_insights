library(markdown)
library(shiny)

source('data_preprocessing.R')

ui <- fluidPage(
  
  titlePanel(h2(strong("The effects of COVID-19 on the US working population"))),
  
  navlistPanel(
    
    tabPanel("Introduction and General Findings",
             
        h2(strong("Welcome!")),
        h4("~~ presented by Shauna Han, Toby Law, Wenyi Li and Nicole Wang ~~"),
        hr(),
        
        h3(strong("Project Introduction")),
        p("The COVID-19 pandemic has reshaped the U.S. job market more than any 
          other event since at least the Great Recession of 2007-09, and the 
          financial panic that followed. As the COVID-19 pandemic brought the 
          economy to a sudden halt, the number of layoffs have increased sharply 
          compared to the pre-COVID times. Most non-essential workers had to 
          adapt from making their home their workplace, and this obviated the 
          commute to and from work daily for a significant portion of the US 
          population. Using the labor statistics data, movement range maps data,
          and tweets, we aim to explore how the COVID-19 has affected the 
          working population of the United States. We address this question by 
          examining the state trends in unemployment rate, differences in daily 
          movement patterns of the population, and changes in wage and working 
          hours in different industries. The data we collected are from the U.S.
          Bureau of Labor Statistics, Meta's Data for Good, and Twitter."),
        
        h3(strong("General Findings")),
        p("This project aims to visualize COVID-19's impact on the US working 
          population from multiple perspectives. The measurements that we 
          selected are great indicators that reflect the state of the US labor 
          market, and we captured interesting patterns through our visualizations. 
          We found similar fluctuation patterns in the trends of unemployment 
          rate, weekly wage and weekly hours among various industries, which 
          echoes the severity of the pandemic, the policy and economic situation
          at that time; the key words extracted from Twitter also reflect trends
          in people's attitudes toward the labor market during the pandemic; 
          the population movement map captures the widespread impact of the 
          pandemic on people's daily commute patterns and movement ranges.")),
    
    tabPanel("Working wages and hours", ##### Wenyi's part----------------------
        
        h2(strong("Changes in Weekly Wage & Weekly Working Hours by Industry")),
        hr(),
        
        h3(strong("Weekly Wage Percentage Change by Industry")),
        br(),
        p("Weekly wages are one of the most important indicators that can reflect 
        the state of the labor market. We aim to visualize the effect of the 
        COVID-19 on weekly wage by different industries, within the time range 
        of 2017 to 2021. Due to the large salary differences between various 
        industries, we have selected the percentage change over the year for 
        each industry. This provides the opportunity to observe fluctuations 
        in weekly wage over time, as well as compare the trends among multiple 
        industries by selecting the industries that interest you. This data was 
        collected from the U.S. Bureau of Labor Statistics."),
        br(),
             
        plotlyOutput(outputId = "weekly_wage_plot"),
        
        br(),     
        p("The above visualization plot shows that the fluctuation pattern of 
        weekly wage percentage change over the year varies in industries. 
        At pre-Covid time, weekly wages in all industries plummeted in the third
        quarter in 2017; at the beginning of the pandemic, arts, information and
        educational services industries had sudden increases, while other 
        industries were either not affected too much, or had sharp declines 
        (accommodation and mining); during the fourth quarter of 2020 and the 
        first quarter of 2021, all the industries had sharp rises and sharp 
        declines, respectively; some industries hit the lowest record of wage 
        percentage change at the first quarter of 2021."),
        
        hr(),
        h3(strong("Change in Weekly Working Hours by Industry")),  
        br(),
        p("Working hours are another important indicator of the labor market. 
        We aim to visualize how weekly working hours in different industries 
        were affected by the COVID-19.  This data was collected from the U.S. 
        Bureau of Labor Statistics."),
        br(),
             
        plotlyOutput(outputId = "weekly_hours_plot"),
        
        br(),     
        p("The above visualization plot shows that workers in most industries have
        had to reduce their working hours as a result of the pandemic, the sharp
        reduction in working hours has been accompanied by an equally sharp 
        decline in income that corresponds to the weekly wage visualization. 
        At the same time, some industries such as arts, information and 
        administrative services experienced increasing of working hours at the 
        second quarter of 2020 (the initial stage of the Covid), which indicates
        the change of people's way of living -- reducing face-to-face activities
        and shifting to remote activities.")),
    
    tabPanel("Unemployment", ##### Nicole's part -------------------------------
             
       h2(strong("US national, industrial and state average unemployment rates")),
       hr(),
       
       h3(strong("Overview")),
       br(),
       p("In March 2020, the US imposed travel restrictions in almost all 50 
        states to reduce the spread of COVID-19. For the vast majority of 330 
        million Americans, public life was paralyzed. Many shops, malls and 
        businesses were closed; restaurants and hotels were empty. Many 
        employees of these companies were forced to apply for unemployment 
        benefits because they lost their jobs. We want to investigate the 
        unemployment situation under the epidemic in the US, we used 
        unemployment rate datasets provided by the U.S. BUREAU OF LABOR 
        STATISTICS to show how Covid-19 affected the unemployment rate in the 
        US."),

       h3(strong("US National Unemployment Rate Over Time")), 
       p("This visualization captures changes in average national unemployment
       rates over time which includes semi-annual data from 2016 to 2021. 
       Users can interact with the plot by clicking on each data point to 
       see the exact dates and rates."),
       br(),
       plotlyOutput(outputId = "national_avg"),
       br(),
       p("The line chart shows a clear pattern that there was a surge 
       increasement in unemployment rate started from 2020 - it jumped from
       3.6% to 11% from Dec.2019 to June.2020. But after the peak, following
       policy easing and the recovery of economic of US, the unemployment
       rate is slowly decreasing and gradually returning to pre-pandemic levels."),
       hr(),
       br(),
       
       h3(strong("US Unemployment Rate by Industry throughout the pandemic")),
       p("This visualization captures changes in average national unemployment
       rates over time which includes semi-annual data from 2016 to 2021,
       and segregated by industry."),
       br(),
       plotlyOutput(outputId = "by_industry",
                    height = "800px", width = "1200px"),
       br(),
       p("The facet plots show different patterns of unemployment rate in US
       industries. Even though they are in different value, but most of them 
       have very similar pattern: a surge in 2020 and 
       gradual decreasement in 2021. The leisure and hospitality industry had
       the largest increasement in unemployment rate from under 10% to 
       above 30%. The reason behind this is obvious since the industry is mainly 
       driven by tourism. At the height of the pandemic in early 2020, the US 
       imposed travel bans to non-citizens, whereas citizens were also more
       reluctant to travel out of uncertainty of the severity and risk of the 
       disease. Therefore employees in those industries were definitely the 
       most hard hit by the pandemic when it first arose."),
       hr(), 
       br(),
       
       h3(strong("Map of Average Unemployment Rates by US State")),
       br(),
       p("Next, we want to investigate the effect of unemployment rates across 
       geographic regions. The map shows the unemployment rates in US States. 
       data from 2019 to 2021 is included, which is before and after the height 
       of the epidemic. Users can choose the year at the upper right corner and 
       see the map of that year."),
       br(),
       leafletOutput(outputId = "rate_map"), 
       br(),
       p("The map shows how unemployment rate changes in US States before and 
        after the height of the COVID-19 epidemic, we can see that almost all 
        of the states have increasement in 2020 even though at different levels.
        The unemployment rate of California became higher in 2020 because 
        California was one of the states with the most Covid-19 cases and most 
        stringent regulations and policies.")),
    
    tabPanel("Twitter text analysis", ##### Shauna's part ----------------------
    
        h2(strong("Twitter Text Analysis about Unemployment during the COVID-19 pandemic")),
        hr(),
        
        h3(strong("Overview")),
        br(),
        p("We extracted tweets using Twitter API to understand how people 
        perceive about the unemployment situation in the United States. 
        We downloaded 500 tweets for three time periods: 2019, 2020, and 
        2021, querying tweets only from US location and with the term 
        'unemployment' in the tweets. The time interval for data we scrapped 
        for the pre-covid period is from Jan to June 2019, and we selected Jan 
        to June 2020 and July to Dec 2021 as pandemic time periods. We analyzed 
        using three different visualization techniques: word clouds, frequent 
        terms bar chart, and sentiment analysis."),
        hr(),
         
        h3(strong("Word Clouds")),
        br(),
        h4(strong("Word Clouds using Unemployment Tweets in 2019, 2020, 2021 
        respectively.")),
        p("From the word clouds, we observed that most frequent words in the 
        pre-covid period were \"economy\", \"rate\", \"black\", the presidents 
        \"obama\" and \"trump\", and \"lowest\"."),
        plotOutput(outputId = "word_cloud_19", height = "550px"),
        br(),
        p("During the pandemic in 2020 and 2021, most frequent words in tweets 
        related to unemployment were \"trump\", \"bill\", \"americans\", 
        \"covid\", \"low\", \"pandemic\", and \"biden\"."),
        plotOutput(outputId = "word_cloud_20", height = "550px"),
        plotOutput(outputId = "word_cloud_21", height = "700px"),
        hr(),
        
        h3(strong("Word Frequency Visualization")),
        br(),
        h4(strong("Word Frequency Visualizations in 2019, 2020, 2021 respectively.")),
        br(),
        p("Most freuqent terms in unemployment tweets in 2019 were \"rate\", 
        \"economy\", \"lowest\", and \"black\". This is the result from the 
        pre-covid time, so we could observe that even during the time prior to 
        the pandemic, Americans were not very content with the unemployment 
        situation in the U.S."),
        br(),
        plotOutput(outputId = "word_freq_19"),
        br(),
        p("The most frequent terms in 2020 and 2021 were \"bill\", \"covid\", 
        \"relief\", \"job\", \"low\", \"biden\", \"back\", and \"americans\". 
        From these selected top words, it seems that people are looking for 
        change and relief."),
        br(),
        plotOutput(outputId = "word_freq_20"),
        br(),
        plotOutput(outputId = "word_freq_21"),
        hr(),
        
        h3(strong("Sentiment Analysis")),
        p("We performed sentiment analysis using the Bing lexicon. It seems that 
        in 2019, the proportion of positive and negative words appeared are 
        equally distributed. Although the number of counts of negative words 
        appeared are somewhat greater than that of positive words, the it seems 
        that there were more variety of positive sentiments appeared in 2019 
        tweets, contributing to the total counts of positive words in 2019 tweets."),
        br(),
        plotOutput(outputId = "sentiment_19"),
        br(),
        p("During the pandemic, more words with negative sentiment appeared in 
        unemployment related tweets, which is evident in the below graph. 
        As the pandemic started and the economy went down, the unemployment 
        tweets had about twice more negative words."),
        br(),
        plotOutput(outputId = "sentiment_20"),
        plotOutput(outputId = "sentiment_21"),
        hr(),
             
        h3(strong("Most Frequent Positive and Negative Words in Tweets")),
        br(),
        h4(strong("Sentiment Analysis using Word Cloud for 2019, 2020, 2021 
        respectively.")),
        br(),
        p("From the word clouds below, it seems that the key words in each 
        year seem to be \"booming\", \"relief\", and \"recovery\". From these 
        keywords, we could assume the message people had about the employment 
        situation during the time. In 2019, people were concerned on economic 
        reform and how to improve the employment rate and decrease poverty."),
        plotOutput(outputId = "senti_cloud_19", height = "1000px"),
        p("Once the pandemic started, in 2020, people were concerned about (job) 
        loss, as the words \"lost\", \"lapsed\", \"losing\", \"lose\" occured 
        frequently. In 2021, from the result, we could suppose that the economic 
        situation is getting better compared to the prior year, as more positive 
        words appeared, such as \"recovery\", \"relief\", \"support\", 
        \"enhanced\", \"happy\", \"easy\", and \"promise\"."),
        plotOutput(outputId = "senti_cloud_20", height = "1000px"),
        plotOutput(outputId = "senti_cloud_21", height = "1000px")),
    
    tabPanel("Movement Range Maps", ##### Toby's part --------------------------
        
        h2(strong("Movement range effects at the height of the COVID-19 pandemic in 2020")),
        hr(),
        
        # Output 1: National map of state averages ----
        h3(strong("Overview")),
        br(),
        p("The COVID-19 pandemic has brought about many changes in people's daily 
        life, and some of the most widespread effects include implementation of 
        stay-at-home orders, social distancing measures and work from home 
        policies. Most non-essential workers had to adapt from making their home 
        their workplace, and this obviated the commute to and from work daily for
        a significant portion of the US population."),
        p("Meta's movement range records measures the proportion of facebook users
        (who have consented to sharing their location) that stay put within a 600
        metre-squared area/tile each day, compared to a baseline value recorded in
        February 2020, i.e. the pre-COVID-19 era."),
        p("US County-level measurements were recorded for every 
        single day from March 5th 2020, up to the time of writing in May 2022. 
        This presents a unique opportunity to visualize how widespread the effect 
        COVID-19 public health measures had on the movement range of citizens 
        nationwide, and to observe how it has fluctuated over the first waves of 
        the pandemic."),
        br(),
        hr(), 
        
        h3(strong("State daily averages of population movement")),
        br(),
        p("We aggregate county measures by state level to visualize changes on a 
        national level over the course of the COVID-19 pandemic."),
        p("COVID-19 was declared a pandemic by the World Health Organization on 
        March 11, 2020, and a national emergency by former president Trump, on 
        March 13. This began the roll out of social distancing and stay-at-home 
        orders, and gradually more and more people nationwide who have the 
        option to work from home are staying put. In mid-April 2020, we can 
        observe a clear increase in the proportion of the population staying put, 
        compared to March. A similar increase can be seen in mid August,
        end of October, as well as the beginning of December. "),
        br(),
        # Leaflet output:
        leafletOutput("state_avg"),
        br(),
        hr(),
        
        # Input: Slider for the Date ----
        p("Toggle along the timeline to see how the proportion of population 
        staying put changes with time."),
        sliderInput(inputId = "Dates",
                   label = "Date:",
                   min = as.Date("2020-03-01","%Y-%m-%d"),
                   max = as.Date("2020-12-31","%Y-%m-%d"),
                   value=as.Date("2020-03-01"),
                   timeFormat="%Y-%m-%d",
                   width = "100%"),
             
        # Output 2: map of county level values ----
        br(),
        hr(),
        h3(strong("Population movement over time, County Level")),
        br(),
        p("For higher resolution of the county movements, refer to this map here.
        Note that counties colored as grey do not have records."),
        br(),
        # Leaflet output:
        leafletOutput("county_level")),
    
    widths = c(2, 8)
  )
)
