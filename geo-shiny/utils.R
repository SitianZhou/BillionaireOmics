#' @title Utilities for Shiny App building
#' 

if(!require(tidyverse))
  install.packages("tidyverse")

if(!require(rnaturalearth))
  install.packages("rnaturalearth")

if(!require(rnaturalearthdata))
  install.packages("rnaturalearthdata")

if(!require(plotly))
  install.packages("plotly")

if(!require(leaflet))
  install.packages("leaflet")

if(!require(sf))
  install.packages("sf")

if(!require(janitor))
  install.packages("janitor")

if(!require(shinydashboard))
  install.packages("shinydashboard")

if(!require(shiny))
  install.packages("shiny")

if(!require(DT))
  install.packages("DT")

library(tidyverse)
library(leaflet)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(plotly)

############### !!! REMEMEBER TO CHANGE DATA DIR !!! ###############
# specify data dir
# data_dir = "../data/" # repo
data_dir = "./data/" # deployment
############### !!! REMEMEBER TO CHANGE DATA DIR !!! ###############

# load data 
bil_gdp = read_csv(paste0(data_dir, "tidy/billionaire_gdp.csv")) 
bil_gdp = bil_gdp |>
  select(-wealth_status) |>
  mutate(gender = factor(ifelse(is.na(gender), "Unknown", gender)),
         year = as.integer(year),
         age = as.integer(age),
         country_of_residence = factor(country_of_residence),
         country_of_citizenship = factor(country_of_citizenship),
         region_code = factor(region_code),
         industries = factor(ifelse(is.na(industries), "Unknown", industries)),
         self_made = factor(ifelse(is.na(self_made), "Unknown", self_made))
         )
# geo data
world_polygon = ne_countries(scale = "medium", returnclass = "sf")
world_point = st_point_on_surface(world_polygon)

gdp_data = read_csv(paste0(data_dir, "raw/gdp_worldbank.csv"), skip = 4) |>
  janitor::clean_names() |>
  select(country_name, country_code, starts_with("x")) |>
  pivot_longer(cols = starts_with("x"), names_to = "year", names_prefix = "x", values_to = "value") |>
  mutate(gdp = value/1e12, 
         year = as.integer(year),
         name = country_name, 
         code = country_code) |>
  filter(year >= 2010) |>
  select(name, code, year, gdp)

year_selection = function(target_year){
  gdp_data |>
    filter(year == target_year) |>
    left_join(world_polygon, by = join_by(code == adm0_a3)) |>
    st_as_sf()
}

billionaire_marker = function(target_year){
  bil_viz = bil_gdp |>
    filter(year == target_year) |>
    group_by(region_code, year) |>
    arrange(desc(net_worth)) |>  # Arrange in descending order based on 'value'
    mutate(rnk = row_number()) |>  # Add rank labels
    filter(rnk <= 1) |>
    mutate(info = paste("<strong>Top 1 Billionaire: </strong>", full_name, 
            "<strong>Industry: </strong>" , industries, 
            "<strong>Wealth: </strong>", paste0(net_worth, " billion"), sep = "<br>")) |>
    left_join(world_point, by = join_by(region_code == adm0_a3)) |>
    st_as_sf()
}

region_options = function(){
  bil_gdp |>
  arrange(region_code) |>
  mutate(region = str_c(country_of_residence, " (", region_code, ")")) |>
  group_by(region, year) |>
  filter(n() >= 5) |>
  select(region) |>
  distinct(region) |>
  filter(!is.na(region)) |>
  pull(region) |> unique() |> factor()
}

extract_code = function(region){
  str_extract(region, "\\((.+)\\)") |>
    str_remove_all("\\(") |>
    str_remove_all("\\)")
}