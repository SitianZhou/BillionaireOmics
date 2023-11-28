#' @title Utilities for Shiny App building
#' 

library(tidyverse)
library(leaflet)
library(sf)
library(rnaturalearth)
library(plotly)

# load data 
world <- ne_countries(scale = "medium", returnclass = "sf")
bil_gdp = read_csv("../data/tidy/billionaire_gdp.csv") 
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

gdp_data = read_csv("../data/raw/gdp_worldbank.csv", skip = 4) |>
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
    left_join(world, by = join_by(code == adm0_a3)) |>
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