server <- function(input, output){
  
  #### Wenyi's work-------------------------------------------------------------
  output$weekly_wage_plot <- renderPlotly({
    
    g1 <- ggplot(weekly_wage, aes(year, 
                                  percentChange, 
                                  text=paste("Time:",year,"<br />Industry:",
                                             industry,"<br />Percent change:",
                                             percentChange*100,"%"))) + 
      scale_y_continuous(labels = scales::percent_format(accuracy = 1)) + 
      geom_path(aes(color = industry, group = industry)) + 
      theme(axis.text.x = element_text(angle = 60, vjust = 0.5)) +  
      ylab("% Change Over the Year") +  
      theme(axis.title.x=element_blank(), 
            panel.background = element_rect(fill='transparent') ) + 
      theme(plot.title = element_text(size=12))
    ggplotly(g1, tooltip = c("text"))
  })
  
  output$weekly_hours_plot <- renderPlotly({
    
    hours_axis_var_names <- c("Construction", "Mining", "Manufacturing", 
                              "WholesaleTrade", "RetailTrade", "Transportation",
                              "Information", "Finance", "RealEstate", 
                              "ProfessionalServices", "ManagementCompanies", 
                              "AdministrativeServices", "HealthCare", "Arts", 
                              "Accommodation")
    
    create_hours_buttons <- function(weekly_hours, hours_axis_var_names) {
      lapply(
        hours_axis_var_names,
        FUN = function(var_name, weekly_hours) {
          button <- list(
            method = 'restyle',
            args = list('y', list(weekly_hours[,var_name])),
            label = sprintf(var_name)
          )
        },
        weekly_hours
      )
      
    }
    
    plot_ly(weekly_hours, x = ~time, y = ~Construction, 
            type = 'scatter', mode = 'lines') %>%
      layout(
        xaxis = list(showgrid = FALSE, title = FALSE),
        yaxis = list(title = FALSE),
        updatemenus = list(
          list(
            buttons = create_hours_buttons(weekly_hours, hours_axis_var_names),
            pad = list('r'= 15, 't'= 10, 'b' = 0)
          )
        ))
  })
  
  #### Nicole's work------------------------------------------------------------
  output$national_avg <- renderPlotly({
    
    total1 <- total %>% 
      gather("id", "value", 2:13) %>%
      filter(id == "Jun"|id == "Dec", Year >= 2016 & Year != 2022)
    
    total1$month <- match(total1[, 2], month.abb)
    
    total1$Date <- paste(total1$Year,total1$month)
    total1$Date <- ym(total1$Date)
    
    total1 <- total1 %>%
      arrange(Date)
    

    plot1 <- plot_ly(total1, x = ~Date, y = ~value, type = 'scatter', mode = 'lines+markers', text = ~value) %>%
      layout(
        xaxis = list(showgrid = FALSE, title = "Year"),
        yaxis = list(title = "Unemployment Rate %")
        
      )
    
  })
  
  output$by_industry <- renderPlotly({
    
    ind <- industry %>% 
      gather("id", "value", 3:6)
    
    ind1 = subset(ind, select = -c(3:6))
    
    ind1$Date <- paste(ind1$Year,ind1$id)
    
    ind1$Date <- yq(ind1$Date)
    
    plot2 <- ggplot(ind1, aes(Date, value, col = Industry)) +             # Create ggplot2 plot
      geom_line()+
      facet_wrap(Industry ~., nrow = 5) +
      labs(x="Year", y="Unemployment Rate %") +
      theme_bw() + 
      theme(plot.title=element_text(hjust = 0.5))
    
    ggplotly(plot2) %>% 
      layout(height = 800, width = 1200)
  })
  
  output$rate_map <- renderLeaflet({
    
    state_shp <- readOGR("unemployment/cb_2021_us_state_500k/cb_2021_us_state_500k.shp",
                         verbose = FALSE)
    
    # Joining the proportions to the state spatial object df
    state_rate <- left_join(state_shp@data, statesgeom,
                            by = c("NAME" = "State")) %>%
      replace(is.na(.), 0)
    
    state_shp@data <- state_rate
    
    choro_pal <- colorBin("YlOrRd", domain = state_shp@data$Rate_2020,
                          bins = c(0, 2, 4, 6, 8, 10, 12, 14))
    
    leaflet() %>%
      addProviderTiles("CartoDB", 
                       options = providerTileOptions(minZoom = 4)) %>%
      setView(lng = -98.35, lat = 39.5, zoom = 4) %>%
      setMaxBounds(lng1 = -66.9513812, lat1 = 49.3457868,
                   lng2 = -124.7844079, lat2 = 24.7433195) %>%
      addPolygons(data = state_shp,
                  weight = 1,
                  color = "#6e7f80",
                  fillColor = ~choro_pal(state_shp@data$Rate_2019),
                  fillOpacity = 0.5,
                  label = state_shp$NAME,
                  popup = content3,
                  group = "2019",
                  highlightOptions = highlightOptions(color = "black", 
                                                      weight = 3)) %>%
      addPolygons(data = state_shp,
                  weight = 1,
                  color = "#6e7f80",
                  fillColor = ~choro_pal(state_shp@data$Rate_2020),
                  fillOpacity = 0.5,
                  label = state_shp$NAME,
                  popup = content4,
                  group = "2020",
                  highlightOptions = highlightOptions(color = "black", 
                                                      weight = 3)) %>%
      addPolygons(data = state_shp,
                  weight = 1,
                  color = "#6e7f80",
                  fillColor = ~choro_pal(state_shp@data$Rate_2021),
                  fillOpacity = 0.5,
                  label = state_shp$NAME,
                  popup = content5,
                  group = "2021",
                  highlightOptions = highlightOptions(color = "black", 
                                                      weight = 3)) %>%
      addLegend(pal = choro_pal, 
                values = state_shp@data$X2020, 
                opacity = 0.7, 
                title = "Unemployment rate (2019-2021):</br> State average %", 
                position = "bottomright") %>%
      addLayersControl(overlayGroups = c("2019", "2020", "2021"))
    
  })
  
  ##### Shauna's work-----------------------------------------------------------
  set.seed(1234) 
  
  color <- brewer.pal(9, "GnBu")
  # Drop 2 faintest colors
  color <- color [-(1:4)]
  
  
  output$word_cloud_19 <- renderPlot({
    par(mar = rep(0, 4))
    wordcloud(words = final_df$word, freq = final_df$freq,
              max.words = 100, colors = color)
  })
  
  output$word_cloud_20 <- renderPlot({
    par(mar = rep(0, 4))
    wordcloud(words = final_df2$word, freq = final_df2$freq,
              max.words = 100, colors = color) 
  })
  
  output$word_cloud_21 <- renderPlot({
    par(mar = rep(0, 4))
    wordcloud(words = final_df3$word, freq = final_df3$freq,
              max.words = 100, colors = color)
  })
  
  output$word_freq_19 <- renderPlot({
    p_1 <- final_df %>%  filter(word!="trump") %>%  
      filter(word!="realdonaldtrump") %>% 
      filter(freq > 30) %>% 
      anti_join(get_stopwords(source = "smart")) %>%  
      ggplot(.,aes(x=reorder(word, freq), freq ,fill=freq)) +
      coord_flip() +
      labs(title="Most Frequent Terms in Unemployment Related Tweets in 2019", 
           x="Words", y= "Frequency") +
      geom_bar(stat="identity",width=0.6,alpha=1) +
      scale_fill_gradientn(colors=wes_palette(name="Moonrise3")) +
      theme_classic() +
      theme(legend.position = "none")
    
    p_1
  })
  
  output$word_freq_20 <- renderPlot({
    p2_2 <- final_df2 %>%  filter(word2!="trump") %>%  
      filter(word2!="realdonaldtrump") %>%  
      filter(word2!="can") %>%  filter(word2!="get")  %>%  
      filter(word2!="just") %>% filter(word2!="will") %>% 
      filter(word2!="week")%>% 
      
      filter(freq2 > 35) %>% #anti_join(get_stopwords(source = "smart")) %>%  
      ggplot(.,aes(x=reorder(word2, freq2), freq2 ,fill=freq2)) +
      coord_flip() +
      labs(title="Most Frequent Terms in Unemployment Related Tweets in 2020", 
           x="Words", y= "Frequency") +
      geom_bar(stat="identity",width=0.6,alpha=1) +
      scale_fill_gradientn(colors=wes_palette(name="Moonrise3")) +
      theme_classic() +
      theme(legend.position = "none") 
    
    
    p2_2
  })
  
  output$word_freq_21 <- renderPlot({
    p3_3 <- final_df3 %>%  filter(word3!="trump") %>%  
      filter(word3!="realdonaldtrump") %>%  
      filter(word3!="can") %>%  
      filter(word3!="get")  %>%  
      filter(word3!="just") %>%  
      filter(word3!="year") %>% 
      filter(word3!="work") %>% filter(word3!="time") %>% 
      filter(freq3 > 35) %>% #anti_join(get_stopwords(source = "smart")) %>%  
      ggplot(.,aes(x=reorder(word3, freq3), freq3 ,fill=freq3)) +
      coord_flip() +
      labs(title="Most Frequent Terms in Unemployment Related Tweets in 2021", 
           x="Words", y= "Frequency") +
      geom_bar(stat="identity",width=0.6,alpha=1) +
      scale_fill_gradientn(colors=wes_palette(name="Moonrise3")) +
      theme_classic() +
      theme(legend.position = "none") 
    
    p3_3
  })
  
  output$sentiment_19 <- renderPlot({
    
    senti <- get_sentiments("bing") %>% filter(word!="trump")
    
    bing <- cleaned_twt%>% 
      inner_join(senti)%>%
      count(word,sentiment, sort=TRUE)%>% 
      filter(sentiment!="trump")   %>% filter(word!="benefits") %>%
      ungroup()
    
    bing%>%
      group_by(sentiment)%>%
      mutate(word=reorder(word,n))%>%
      top_n(10)%>%
      ggplot(aes(word,n,fill=sentiment))+
      geom_col(show.legend=FALSE)+
      facet_wrap(~sentiment,scale="free_y")+
      labs(title='Setiment Analysis on Unemployment Tweets in 2019',
           y='Contribution to Sentiment')+
      coord_flip()+
      theme_classic() 
    
  })
  
  output$sentiment_20 <- renderPlot({
    
    senti2 <- get_sentiments("bing") %>% filter(word!="trump")
    
    bing2 <- cleaned_twt2%>% 
      inner_join(senti2)%>%
      count(word,sentiment, sort=TRUE)%>% 
      filter(sentiment!="trump")   %>% filter(word!="benefits") %>%
      ungroup()
    
    bing2%>%
      group_by(sentiment)%>%
      mutate(word=reorder(word,n))%>%
      top_n(10)%>%
      ggplot(aes(word,n,fill=sentiment))+
      geom_col(show.legend=FALSE)+
      facet_wrap(~sentiment,scale="free_y")+
      labs(title='Setiment Analysis on Unemployment Tweets in 2020',
           y='Contribution to Sentiment')+
      coord_flip()+
      theme_classic() 
    
  })
  
  output$sentiment_21 <- renderPlot({
    
    senti <- get_sentiments("bing") %>% filter(word!="trump")
    
    bing3 <- cleaned_twt3%>% 
      inner_join(senti)%>%
      count(word,sentiment, sort=TRUE)%>% 
      filter(sentiment!="trump")   %>% filter(word!="benefits") %>%
      ungroup()
    
    bing3%>%
      group_by(sentiment)%>%
      mutate(word=reorder(word,n))%>%
      top_n(10)%>%
      ggplot(aes(word,n,fill=sentiment))+
      geom_col(show.legend=FALSE)+
      facet_wrap(~sentiment,scale="free_y")+
      labs(title='Setiment Analysis on Unemployment Tweets in 2021',
           y='Contribution to Sentiment')+
      coord_flip()+
      theme_classic()
    
  })
  
  output$senti_cloud_19 <- renderPlot({
    
    senti.bing <- df %>%
      unnest_tokens(word, text) %>%               # split text into words
      anti_join(stop_words, by = "word") %>%              # remove stop words
      # filter(!grepl('[0-9]', word !="trump")) %>% 
      filter(word!="trump") %>% filter(word!="benefits") %>%
      # remove numbers
      inner_join(get_sentiments("bing"), by = "word") 
    
    senti.bing%>%
      count(word, sentiment, sort = TRUE) %>%
      acast(word ~ sentiment, value.var = "n", fill = 0) %>% #convert tibble into matrix
      comparison.cloud(colors = c("red", "blue"),
                       max.words = 200)
    
  })
  
  output$senti_cloud_20 <- renderPlot({
    
    senti.bing2 <- df2 %>%
      unnest_tokens(word, text) %>%                
      anti_join(stop_words, by = "word") %>%       
      filter(word!="trump") %>% filter(word!="benefits") %>%
      inner_join(get_sentiments("bing"), by = "word") 
    
    
    senti.bing2%>%
      count(word, sentiment, sort = TRUE) %>%
      acast(word ~ sentiment, value.var = "n", fill = 0) %>%  #convert tibble into matrix
      comparison.cloud(colors = c("red", "blue"),
                       max.words = 200)
    
  })
  
  output$senti_cloud_21 <- renderPlot({
    senti.bing3 <- df3 %>%
      unnest_tokens(word, text) %>%                
      anti_join(stop_words, by = "word") %>%       
      filter(word!="trump") %>% filter(word!="benefits") %>%
      inner_join(get_sentiments("bing"), by = "word") 
    
    
    senti.bing3%>%
      count(word, sentiment, sort = TRUE) %>%
      acast(word ~ sentiment, value.var = "n", fill = 0) %>% 
      comparison.cloud(colors = c("red", "blue"),
                       max.words = 200)
  })
  
  ##### Toby's work-------------------------------------------------------------
  
  output$state_avg <- renderLeaflet({
    
    weekly_state_avg <- usa_weekly_avg_state %>%
      filter(week == input$Week) # where the date toggle input will be
    
    state_temp <- state_shp
    
    # Joining the proportions to the state spatial object df
    weekly_state_avg_df <- left_join(state_temp@data, weekly_state_avg,
                                     by = c("STUSPS" = "State")) %>%
      replace(is.na(.), 0)
    
    state_temp@data <- weekly_state_avg_df
    
    
    leaflet() %>%
      addProviderTiles("CartoDB", 
                       options = providerTileOptions(minZoom = 4)) %>%
      setView(lng = -98.35, lat = 39.5, zoom = 4) %>%
      setMaxBounds(lng1 = -66.9513812, lat1 = 49.3457868,
                   lng2 = -124.7844079, lat2 = 24.7433195) %>%
      addPolygons(data = state_temp,
                  weight = 1,
                  color = "#6e7f80",
                  fillColor = ~choro_pal(weekly_state_avg_df$avg_stay_put),
                  fillOpacity = 0.5,
                  label = state_temp$NAME,
                  popup = paste("Proportion of users staying put:",
                                state_temp$avg_stay_put,
                                "<br/>",
                                "State:",
                                state_temp$NAME,
                                "<br/>"),
                  highlightOptions = highlightOptions(color = "black", 
                                                      weight = 3)) %>%
      addLegend(pal = choro_pal, 
                values = weekly_state_avg_df$avg_stay_put, 
                opacity = 0.7, 
                title = "Proportion of </br> users staying put:</br> State weekly average", 
                position = "bottomright")
    
  })
  
  output$county_level <- renderLeaflet({
    
    county_week <- usa_weekly_avg_county %>%
      filter(week == input$Week)
    
    county_temp <- county_shp
    
    # Joining the proportions to the county spatial object df
    weekly_county_df <- left_join(county_temp@data, county_week,
                                  by = c("NAME" = "County",
                                         "STUSPS" = "State")) %>%
      replace(is.na(.), 0)
    
    county_temp@data <- weekly_county_df
    
    
    leaflet() %>%
      addProviderTiles("CartoDB", 
                       options = providerTileOptions(minZoom = 4)) %>%
      setView(lng = -98.35, lat = 39.5, zoom = 4) %>%
      setMaxBounds(lng1 = -66.9513812, lat1 = 49.3457868,
                   lng2 = -124.7844079, lat2 = 24.7433195) %>%
      addPolygons(data = county_temp,
                  weight = 1,
                  color = "#6e7f80",
                  fillColor = ~choro_pal(weekly_county_df$avg_stay_put),
                  fillOpacity = 0.5,
                  label = county_temp$NAME,
                  popup = paste("Proportion of users staying put:",
                                county_temp$avg_stay_put,
                                "<br/>",
                                "State:",
                                county_temp$STATE_NAME,
                                "<br/>",
                                "County:",
                                county_temp$NAME),
                  highlightOptions = highlightOptions(color = "black", 
                                                      weight = 3)) %>%
      addLegend(pal = choro_pal, 
                values = weekly_county_df$avg_stay_put, 
                opacity = 0.7, 
                title = "Proportion of users </br> staying put: </br> County weekly average", 
                position = "bottomright")
  })
  
}