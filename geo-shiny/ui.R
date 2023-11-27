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

# Define UI for application
header = dashboardHeader(
  title = "BillionairesOmics"
)

sidebar = dashboardSidebar(
  sidebarMenu(
    menuItem("Global Map", tabName = "dashboard", icon = icon("map")),
    menuItem("Chart", tabName = "charts", icon = icon("chart-bar"),
        menuSubItem("Inter-Region", tabName = "view1"),
        menuSubItem("Intra-Region", tabName = "view2")
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
                sliderInput("mapYear", "Select Year:", 
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

h = 200
view1 = fluidRow(
    
    column(width = 8,
        box(width = "50%", solidHeader = TRUE,
            plotlyOutput("view1a", height = h),
            plotlyOutput("view1b", height = h),
            plotlyOutput("view1c", height = h),
            plotlyOutput("view1d", height = h)
        )
    ), 
    column(width = 4,
        box(width = "100%", solidHeader = TRUE,
            sliderInput("view1Year", "Select Year:", 
                min = 2010, max = 2022, value = 2022)
        ),
        box(width = "100%", solidHeader = TRUE,
            sliderInput("view1Age", "Select Age:", 
                min = 1, max = 100, value = c(1, 100))
        )
    )
)

view2 = fluidRow(
    
)


body = dashboardBody(
    tabItems(
        tabItem(tabName = "dashboard", map),
        tabItem(tabName = "view1", view1),
        tabItem(tabName = "view2", view2),
        tabItem(tabName = "data", db)
    )
)

# test_body = fluidRow(
#     column(width = 9,
#       box(width = NULL, solidHeader = TRUE,
#         leafletOutput("busmap", height = 500)
#       ),
#       box(width = NULL,
#         uiOutput("numVehiclesTable")
#       )
#     ),
#     column(width = 3,
#       box(width = NULL, status = "warning",
#         uiOutput("routeSelect"),
#         checkboxGroupInput("directions", "Show",
#           choices = c(
#             Northbound = 4,
#             Southbound = 1,
#             Eastbound = 2,
#             Westbound = 3
#           ),
#           selected = c(1, 2, 3, 4)
#         ),
#         p(
#           class = "text-muted",
#           paste("Note: a route number can have several different trips, each",
#                 "with a different path. Only the most commonly-used path will",
#                 "be displayed on the map."
#           )
#         ),
#         actionButton("zoomButton", "Zoom to fit buses")
#       ),
#       box(width = NULL, status = "warning",
#         selectInput("interval", "Refresh interval",
#           choices = c(
#             "15 seconds" = 15,
#             "30 seconds" = 30,
#             "1 minute" = 60,
#             "2 minutes" = 120,
#             "5 minutes" = 300,
#             "10 minutes" = 600
#           ),
#           selected = "60"
#         ),
#         uiOutput("timeSinceLastUpdate"),
#         actionButton("refresh", "Refresh now"),
#         p(class = "text-muted",
#           br(),
#           "Source data updates every 15 seconds."
#         )
#       )
#     )
#   )

dashboardPage(
  header,
  sidebar,
  body
)