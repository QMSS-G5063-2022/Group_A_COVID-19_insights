# Unemployment rates (national, industrial and stage averages)
library(ggplot2)
library(tidyverse)
library(zoo)
library(dplyr)
library(lubridate)
library(plotly)
library(devtools)
library(leaflet)
library(readr)
library(rgdal)
library(tmap)
library(ggmap)
library(RColorBrewer)
library(shiny)

## Importing datasets

total <- read.csv("SeriesReport-20220423235636_21d8c2.csv", 
                  stringsAsFactors = FALSE,
                  fileEncoding="UTF-8-BOM")
states <- read.csv("unemployment by states.csv", 
                   stringsAsFactors = FALSE,
                   fileEncoding="UTF-8-BOM")
industry <- read.csv("Unempolyment rate by industry.csv", 
                     stringsAsFactors = FALSE,
                     fileEncoding="UTF-8-BOM")

# Pre-processing steps for leaflet map
colnames(states)[2] <- 'Rate_2019'
colnames(states)[3] <- 'Rate_2020'
colnames(states)[4] <- 'Rate_2021'

geom <- read.csv("statelatlong.csv")

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


ui <- fluidPage(
  # App title ----
  titlePanel("Unemployment rate changes due to the COVID-19 pandemic"),
  
  # Main panel for displaying outputs ----
  mainPanel(
    h3(strong("Heading here")), 
    p("The first visualization of unemployment rate is a A line chart to capture changes in average national unemployment rates over time."),
    br(),
    plotlyOutput(outputId = "national_avg"),
    br(),
    hr(),
    
    h3(strong("Heading here")),
    p("The second visualization of unemployment rate is shows trend of different industries."),
    br(),
    plotlyOutput(outputId = "by_industry",
                 height = "800px", width = "1200px"),
    br(),
    hr(), 
    
    h3(strong("Heading here")),
    p("The third visualization of unemployment rate is an interactive map of US states."),
    br(),
    leafletOutput(outputId = "rate_map")
  
  )
)
server <- function(input, output){
  
  output$national_avg <- renderPlotly({
    
    total1 <- total %>% 
      gather("id", "value", 2:13) %>%
      filter(id == "Jun"|id == "Dec", Year >= 2016 & Year != 2022)
    
    total1$month <- match(total1[, 2], month.abb)
    
    total1$Date <- paste(total1$Year,total1$month)
    total1$Date <- ym(total1$Date)
    
    plot1 <- ggplot(total1, aes(Date, value)) +
      geom_point() +
      geom_line( color="#69b3a2") +
      theme_classic()+
      labs(x="Year", y="Unemployment Rate %", 
           title="US National Unemployment Rate 2016-2022")+
      theme(plot.title=element_text(hjust = 0.5))
    
    ggplotly(plot1)
    
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
      labs(x="Year", y="Unemployment Rate %", 
           title="US Unemployment Rate by Industry (2019-2021)") +
      theme_bw() + 
      theme(plot.title=element_text(hjust = 0.5))
    
    ggplotly(plot2) %>% 
      layout(height = 800, width = 1200)
  })
  
  output$rate_map <- renderLeaflet({
    
    state_shp <- readOGR("cb_2021_us_state_500k/cb_2021_us_state_500k.shp",
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
  
}

shinyApp(ui = ui, server = server)
