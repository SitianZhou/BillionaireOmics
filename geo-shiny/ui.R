#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(leaflet)
library(DT)
library(plotly)

source("./utils.R")

# Define UI for application
header = dashboardHeader(
  title = "BillionairesOmics"
)

sidebar = dashboardSidebar(
  sidebarMenu(
    menuItem("Global Map", tabName = "dashboard", icon = icon("map")),
    menuItem("Chart", tabName = "charts", icon = icon("chart-bar"),
        menuSubItem("Global", tabName = "view1"),
        menuSubItem("Regional", tabName = "view2")
    ),
    menuItem("Data", tabName = "data", icon = icon("database"))
  )
)

map = fluidRow(
        column(width = 9,
            box(width = NULL, solidHeader = TRUE,
                leafletOutput("map", height = 500)
            ),
        ),
        column(width = 3, 
            box(
                width = "100%",
                sliderInput("mapYear", "Year:", 
                    min = 2010, max = 2022, value = 2022)
            )
        ),
        column(width = 12,
            box(
                width = "100%",
                DTOutput("mapTable")
            )
        )
    )

db = fluidRow(
    box(
        title = "Billionaires Data",
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        autoWidth = TRUE,
        width = "200%",
        DTOutput("datatable")
    )

)

h = 250
view1 = fluidRow(
    
    column(width = 9,
        box(width = "50%", solidHeader = TRUE,
            plotlyOutput("view1a", height = h),
            plotlyOutput("view1b", height = h),
            plotlyOutput("view1c", height = h),
            plotlyOutput("view1d", height = h*1.5)
        )
    ), 
    column(width = 3,
        box(width = "100%", solidHeader = TRUE,
            sliderInput("view1Year", "Year:", 
                min = 2010, max = 2022, value = 2022)
        ),
        box(width = "100%", solidHeader = TRUE,
            sliderInput("view1Age", "Age:", 
                min = 1, max = 100, value = c(1, 100))
        )
    )
)

h = 300
view2 = fluidRow(
    column(width = 9,
        box(width = "50%", solidHeader = TRUE,
            plotlyOutput("view2a", height = h),
            plotlyOutput("view2b", height = h),
            plotlyOutput("view2c", height = h*1.5)
        )
    ),
    column(width = 3,
        box(width = "100%", solidHeader = TRUE,
            sliderInput("view2Year", "Year:", 
                min = 2010, max = 2022, value = 2022)
        ),
        box(width = "100%", solidHeader = TRUE,
            sliderInput("view2Rank", "Rank Range:", 
                min = 1, max = 20, value = c(1, 10))
        ),
        box(width = NULL, solidHeader = TRUE,
            checkboxGroupInput("view2Region", "Region:",
                choices = region_options(), selected = c("United States (USA)", "China (CHN)"))
        )
    )
)


body = dashboardBody(
    tabItems(
        tabItem(tabName = "dashboard", map),
        tabItem(tabName = "view1", view1),
        tabItem(tabName = "view2", view2),
        tabItem(tabName = "data", db)
    )
)

dashboardPage(
  header,
  sidebar,
  body
)