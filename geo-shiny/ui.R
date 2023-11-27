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

# Define UI for application
header = dashboardHeader(
  title = "BillionairesOmics"
)

sidebar = dashboardSidebar(
  sidebarMenu(
    menuItem("Global Map", tabName = "dashboard", icon = icon("map")),
    menuItem("Chart", tabName = "charts", icon = icon("chart-bar"),
        menuSubItem("Age Distribution", tabName = "hist"),
        menuSubItem("Wealth Track", tabName = "track"),
        menuSubItem("Industry Condition", tabName = "industry")
    ),
    menuItem("Data", tabName = "data", icon = icon("database"))
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


body = dashboardBody(
    tabItems(
        tabItem(tabName = "dashboard",
        fluidRow(
            box(width = NULL, solidHeader = TRUE,
            leafletOutput("map", height = 500)
            )
        )
        ),
        tabItem(tabName = "hist",
        fluidRow(
            box(width = NULL, solidHeader = TRUE,
            plotOutput("hist", height = 500)
            )
        )
        ),
        tabItem(tabName = "track",
        fluidRow(
            box(width = NULL, solidHeader = TRUE,
            plotOutput("track", height = 500)
            )
        )
        ),
        tabItem(tabName = "industry",
        fluidRow(
            box(width = NULL, solidHeader = TRUE,
            plotOutput("industry", height = 500)
            )
        )
        ),
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