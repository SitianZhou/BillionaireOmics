#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(leaflet)
library(sf)
library(rnaturalearth)

# Load data
world <- ne_countries(scale = "medium", returnclass = "sf")
bil_gdp = read_csv("../data/tidy/billionaire_gdp.csv") |>
  select(-wealth_status) |>
  mutate(gender = factor(gender),
         year = as.integer(year),
         age = as.integer(age),
         country_of_residence = factor(country_of_residence),
         country_of_citizenship = factor(country_of_citizenship),
         region_code = factor(region_code),
         industries = factor(industries),
         self_made = factor(self_made)
         )
country_gdp = bil_gdp |>
  select(region_code, region_gdp)

# Define server logic required to draw a histogram
function(input, output, session) {

    output$map <- renderLeaflet({
        leaflet() |> 
        addProviderTiles("CartoDB.Positron") |>  # You can choose different tile providers
        addPolygons(data = world, 
                    fillColor = "lightblue", 
                    fillOpacity = 0.3, 
                    color = "white", 
                    weight = 1) 
    })


    output$datatable <- renderDT({
        datatable(bil_gdp,
                  filter = "top",
                  selection = list(target = 'column'),
                  options = list(
                    pageLength = 10,
                    scrollX = TRUE,
                    buttons = c('copy', 'csv', 'excel', 'print', 'colvis'),
                    columnDefs = list(list(
                        searchPanes = list(show = FALSE), targets = 1:4
                        ))
                  )
        )
    })

}
