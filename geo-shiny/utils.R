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
  mutate(gender = factor(gender),
         year = as.integer(year),
         age = as.integer(age),
         country_of_residence = factor(country_of_residence),
         country_of_citizenship = factor(country_of_citizenship),
         region_code = factor(region_code),
         industries = factor(industries),
         self_made = factor(self_made)
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

update_inter_data = function(target_year, target_age_range){
  inter_data = bil_gdp |>
    filter(year == target_year & age >= target_age_range[1] & age <= target_age_range[2])
}

view1a = function(target_year, target_age_range){
  inter_data = update_inter_data(target_year, target_age_range)
  count_by_region = inter_data |>
  group_by(region_code) |>
  summarise(count = n()) |>
  mutate(region_code = fct_reorder(region_code, count))
  
  count_view = count_by_region |>
  filter(count >= 3 & !is.na(region_code)) |>
  ggplot(aes(x = region_code, y = count, fill = "tomato")) +
  geom_bar(stat = "identity") +
  labs(title = "Billionaire Count", x = "Region", y = "Count") +
  theme(axis.text.x = element_text(angle = -90, hjust = 1), 
        legend.position = "none")
  return(ggplotly(count_view))
}

view1b = function(){

}

view1c = function(){

}

view1d = function(){

}


