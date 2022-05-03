# Weekly wage and working hours plots
library(ggplot2)
library(plotly)
library(shiny)

weekly_wage <- read.csv("wage4.csv")
weekly_hours <- read.csv("hours4.csv")

ui <- fluidPage(
  
  # App title ----
  titlePanel("heading to be added"),
  
    # Main panel for displaying outputs ----
    mainPanel(
      
      h3(strong("Changes in Weekly Wage & Weekly Working Hours by Industries")),
      p("Weekly wages are one of the most important indicators that can reflect 
        the state of the labor market. We aim to visualize the effect of the 
        COVID-19 on weekly wage by different industries, within the time range 
        of 2017 to 2021. Due to the large salary differences between various 
        industries, we have selected the percentage change over the year for 
        each industry. This provides the opportunity to observe fluctuations 
        in weekly wage over time, as well as compare the trends among multiple 
        industries by selecting the industries that interest you. This data was 
        collected from the U.S. Bureau of Labor Statistics."),
      
      plotlyOutput(outputId = "weekly_wage_plot"),
      
      p("The above visualization plot shows that the fluctuation pattern of 
        weekly wage percentage change over the year varies in industries. 
        At pre-Covid time, Weekly wages in all industries plummeted in the third
        quarter in 2017; at the beginning of the pandemic, arts, information and
        educational services industries had sudden increases, while other 
        industries were either not affected too much, or had sharp declines 
        (accommodation and mining); during the fourth quarter of 2020 and the 
        first quarter of 2021, all the industries had sharp rises and sharp 
        declines, respectively; some industries hit the lowest record of wage 
        percentage change at the first quarter of 2021."),
      
      p("Working hours are another important indicator of the labor market. 
        We aim to visualize how weekly working hours in different industries 
        were affected by the COVID-19.  This data was collected from the U.S. 
        Bureau of Labor Statistics."),
      
      plotlyOutput(outputId = "weekly_hours_plot"),
      
      p("The above visualization plot shows that workers in most industries have
        had to reduce their working hours as a result of the pandemic, the sharp
        reduction in working hours has been accompanied by an equally sharp 
        decline in income that corresponds to the weekly wage visualization. 
        At the same time, some industries such as arts, information and 
        administrative services experienced increasing of working hours at the 
        second quarter of 2020 (the initial stage of the Covid), which indicates
        the change of people's way of living -- reducing face-to-face activities
        and shifting to remote activities.")
      
    )
)

server <- function(input, output) {
  
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
      ggtitle("Weekly wage (quarterly) % change over the year by industry") + 
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
        title = "Average weekly hours by industry",
        xaxis = list(showgrid = FALSE, title = FALSE),
        yaxis = list(title = FALSE),
        updatemenus = list(
          list(
            buttons = create_hours_buttons(weekly_hours, hours_axis_var_names),
            pad = list('r'= 15, 't'= 10, 'b' = 0)
          )
        ))
  })
  
}

shinyApp(ui = ui, server = server)