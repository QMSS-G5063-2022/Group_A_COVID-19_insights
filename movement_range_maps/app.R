# Movement range maps
library(dplyr)
library(stringr)
library(shiny)
library(leaflet)
library(rgdal)

## Importing usa dataframe
usa <- read.csv("movement_range_data_usa_2020.txt", sep = ",")

# selecting years of interest
usa_2020 <- usa %>%
  filter(year == 2020)

## Establishing the base map
nation_shp <- readOGR("cb_2021_us_nation_5m/cb_2021_us_nation_5m.shp")
county_shp <- readOGR("cb_2021_us_county_500k/cb_2021_us_county_500k.shp")
state_shp <- readOGR("cb_2021_us_state_500k/cb_2021_us_state_500k.shp")


## Building interactive page
ui <- fluidPage(
  
  # App title ----
  titlePanel("Movement Range Maps in the height of the COVID-19 pandemic"),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output 1: National map of state averages ----
      h3(strong("Overview")),
      p("The COVID-19 pandemic has brought about many changes in people's daily 
      life, and some of the most widespread effects include implementation of 
      stay-at-home orders, social distancing measures and work from home 
      policies. Most non-essential workers had to adapt from making their home 
      their workplace, and this obviated the commute to and from work daily for
      a significant portion of the US population."),
      p("Meta's movement range records measures the proportion of facebook users
      (who have consented to sharing their location) that stays put within a 600
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
      
      # Output 2: Zoomable map of county level values ----
      br(),
      hr(),
      h3(strong("Population movement over time, County Level")),
      br(),
      p("For higher resolution of the county movements, refer to this map here.
        Note that counties colored as grey do not have records."),
      br(),
      # Leaflet output:
      leafletOutput("county_level")
      
      
    
  )
)

server <- function(input, output) {
  
  output$state_avg <- renderLeaflet({
    
    daily_state_avg <- usa_2020 %>%
      group_by(State, ds) %>%
      summarize(avg_stay_put = mean(all_day_ratio_single_tile_users)) %>%
      filter(ds == input$Dates) # where the date toggle input will be
    
    state_shp <- readOGR("cb_2021_us_state_500k/cb_2021_us_state_500k.shp")
    
    # Joining the proportions to the state spatial object df
    daily_state_avg_df <- left_join(state_shp@data, daily_state_avg,
                                    by = c("STUSPS" = "State")) %>%
      replace(is.na(.), 0)
    
    state_shp@data <- daily_state_avg_df
    
    choro_pal <- colorBin("YlOrRd", domain = daily_state_avg_df$avg_stay_put,
                          bins = c(0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.5, 0.7, 1))
    
    leaflet() %>%
      addProviderTiles("CartoDB", 
                       options = providerTileOptions(minZoom = 4)) %>%
      setView(lng = -98.35, lat = 39.5, zoom = 4) %>%
      setMaxBounds(lng1 = -66.9513812, lat1 = 49.3457868,
                   lng2 = -124.7844079, lat2 = 24.7433195) %>%
      addPolygons(data = nation_shp,
                  color = "#6e7f80", 
                  weight = 2) %>%
      addPolygons(data = state_shp,
                  weight = 1,
                  color = "#6e7f80",
                  fillColor = ~choro_pal(daily_state_avg$avg_stay_put),
                  fillOpacity = 0.5,
                  label = state_shp$NAME,
                  popup = paste("Proportion of users staying put:",
                                state_shp$avg_stay_put,
                                "<br/>",
                                "State:",
                                state_shp$NAME,
                                "<br/>"),
                  group = "State",
                  highlightOptions = highlightOptions(color = "black", 
                                                      weight = 3)) %>%
      addLegend(pal = choro_pal, 
                values = daily_state_avg$avg_stay_put, 
                opacity = 0.7, 
                title = "Population staying put:</br> State daily average proportion", 
                position = "bottomright") %>%
      addLayersControl(overlayGroups = c("State", "County"))
  })
  
  output$county_level <- renderLeaflet({
    
    county_day <- usa_2020 %>%
      filter(ds == input$Dates)
    
    county_shp <- readOGR("cb_2021_us_county_500k/cb_2021_us_county_500k.shp")
    
    # Joining the proportions to the state spatial object df
    daily_county_df <- left_join(county_shp@data, county_day,
                                 by = c("STUSPS" = "State",
                                        "NAME" = "County")) %>%
      replace(is.na(.), 0)
    
    county_shp@data <- daily_county_df
    
    choro_pal <- colorBin("YlOrRd", domain = daily_county_df$all_day_ratio_single_tile_users,
                          bins = c(0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.5, 0.7, 1))
    
     
    
    leaflet() %>%
      addProviderTiles("CartoDB", 
                       options = providerTileOptions(minZoom = 4)) %>%
      setView(lng = -98.35, lat = 39.5, zoom = 4) %>%
      setMaxBounds(lng1 = -66.9513812, lat1 = 49.3457868,
                   lng2 = -124.7844079, lat2 = 24.7433195) %>%
      addPolygons(data = nation_shp,
                  color = "#6e7f80", 
                  weight = 2) %>%
      addPolygons(data = county_shp,
                  weight = 1,
                  color = "#6e7f80",
                  fillColor = ~choro_pal(daily_county_df$all_day_ratio_single_tile_users),
                  fillOpacity = 0.5,
                  label = county_shp$NAME,
                  popup = paste("Proportion of users staying put:",
                                county_shp@data$all_day_ratio_single_tile_users,
                                "<br/>",
                                "State:",
                                county_shp@data$STATE_NAME,
                                "<br/>",
                                "County:",
                                county_shp$NAME),
                  group = "County",
                  highlightOptions = highlightOptions(color = "black", 
                                                      weight = 3)) %>%
      addLegend(pal = choro_pal, 
                values = daily_county_df$all_day_ratio_single_tile_users, 
                opacity = 0.7, 
                title = "Population staying put - <br/> County level proportion", 
                position = "bottomright") %>%
      addLayersControl(overlayGroups = c("State", "County"))
  })
  
}

shinyApp(ui, server)