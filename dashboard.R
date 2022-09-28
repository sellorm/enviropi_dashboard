library(dplyr)
library(DT)
library(ggplot2)
library(gridExtra)
library(readr)
library(shiny)
library(shinydashboard)

# Config

log_dir <- Sys.getenv("ENVIRO_LOG_DIR",
                      unset = "enviro-logs")

if(!dir.exists(log_dir)){
  stop("Error: Log directory not found. Override by setting the ENVIRO_LOG_DIR env var")
}

# Shinydashboard components

## Sidebar
sidebar <- dashboardSidebar(
  sidebarMenu(
    sh2(textOutput("datetime")),
    selectInput("filepicker",
                "Select date to view:",
                choices = c("today",
                            rev(dir(log_dir, pattern="^enviro_[0-9]{4}-[0-9]{2}-[0-9]{2}[.]log$"))
                )
    ),
    menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
    menuItem("Gasses",
             icon = icon("mask-face"),
             tabName = "gasses",
             badgeLabel = "new",
             badgeColor = "green"),
    menuItem("Raw Data",
             icon = icon("th"),
             tabName = "data",
             badgeLabel = "updated",
             badgeColor = "orange")
  )
)

## Body
body <- dashboardBody(
  tabItems(
    tabItem(tabName = "overview",
            fluidRow(
              box(plotOutput("overview"),
                  width = 12,
                  title = "Overview")
            )
    ),
    
    tabItem(tabName = "gasses",
            
            fluidRow(
              h2("Gasses overview"),
              box(plotOutput("box_gas"),
                  width = 4,
                  title = "Gasses highlights",
                  status = "warning",
                  solidHeader = TRUE),
              box(plotOutput("gasses"),
                  width = 8,
                  title = "Gasses detail",
                  status = "primary",
                  solidHeader = TRUE)
            )
    ),
    
    tabItem(tabName = "data",
            h2("Raw data"),
            fluidRow(
              box(
                dataTableOutput("data"),
                title = "Raw data",
                solidHeader = TRUE,
                width = 12
              )
            )
    )
  )
)


# UI
ui <- dashboardPage(
  dashboardHeader(title = "Local Sensor Dashboard"),
  dashboardSidebar(sidebar),
  dashboardBody(body),
  skin = "red"
)

# Server
server <- function(input, output) {
  sensor_data <- reactive({
    # rlog::log_info(paste0("File Picker value: ", input$filepicker))
    if(input$filepicker == "today"){
      filename <- paste0("enviro_", Sys.Date(), ".log")
    } else {
      filename <- input$filepicker
    }
    readr::read_csv(file.path(log_dir, filename),
                    col_names = c("timestamp",
                                  "proximity",
                                  "temperature",
                                  "air_pressure",
                                  "humidity",
                                  "light",
                                  "oxidising",
                                  "reducing",
                                  "nh3"),
                    show_col_types = FALSE)
  })
  
  # Currently selected data
  output$datetime <- renderText({
    # rlog::log_info(paste0("Timestamp: ", as.character(sensor_data()$timestamp)))
    as.character(as.Date(head(sensor_data()$timestamp, 1)))
  })
  
  # Overview plots
  output$overview <- renderPlot({
    plot_temp <- ggplot(sensor_data(), aes(timestamp, temperature)) +
      geom_line(na.rm=TRUE)
    
    plot_air_pressure <- ggplot(sensor_data(), aes(timestamp, air_pressure)) +
      geom_line(na.rm=TRUE)
    
    plot_humidity <- ggplot(sensor_data(), aes(timestamp, humidity)) +
      geom_line(na.rm=TRUE)
    
    plot_light <- ggplot(sensor_data(), aes(timestamp, light)) +
      geom_line(na.rm=TRUE)
    
    
    grid.arrange(plot_temp,
                 plot_air_pressure,
                 plot_humidity,
                 plot_light,
                 nrow=4)
    
  })
  
  # Gasses plots
  output$gasses <- renderPlot({
    plot_oxidising <- ggplot(sensor_data(), aes(timestamp, oxidising)) +
      geom_line(na.rm=TRUE)
    
    plot_reducing <- ggplot(sensor_data(), aes(timestamp, reducing)) +
      geom_line(na.rm=TRUE)
    
    plot_nh3 <- ggplot(sensor_data(), aes(timestamp, nh3)) +
      geom_line(na.rm=TRUE)
    
    grid.arrange(plot_oxidising,
                 plot_reducing,
                 plot_nh3,
                 nrow=3)
    
  })
  
  output$box_gas <- renderPlot({
    boxplot(sensor_data()[,7:9])
  })
  
  # Tabular output
  output$data <- renderDT({
    raw_data <- sensor_data() %>% select(
      "time" = "timestamp",
      "temp" = "temperature",
      "pressure" = "air_pressure",
      "humidity",
      "light",
      "oxidising",
      "reducing",
      "nh3") %>%
      datatable(
        options = list(lenhMenu = c(10, 100, 250),
                       pageLength = 100)
      )
  })
  
}

shinyApp(ui, server)