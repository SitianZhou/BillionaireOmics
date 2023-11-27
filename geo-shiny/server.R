#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

source("./utils.R")

# Define server logic required to draw a histogram
function(input, output, session) {

    gdp_data = reactive({
        year_selection(input$mapYear)
    })

    output$map <- renderLeaflet({
      leaflet() |>
        addProviderTiles("CartoDB.Positron") |>  # You can choose different tile providers
        addPolygons(data = gdp_data(), 
                    fillColor = ~colorQuantile("YlOrRd", gdp)(gdp), 
                    fillOpacity = 0.3, color = "white", weight = 1,
                    highlightOptions = highlightOptions(
                      color = "black", weight = 2, bringToFront = TRUE)) 
    })

    output$mapTable <- renderDT({
        datatable(gdp_data(),
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

    # inter_data = reactive({
    #     update_inter_data(input$mapYear, input$ageRange)
    # }) 
    output$view1a <- renderPlotly({
      inter_data = bil_gdp |>
        filter(year == target_year & age >= target_age_range[1] & age <= target_age_range[2])

      count_by_region = inter_data |>
        group_by(region_code) |>
        summarise(count = n()) |>
        mutate(region_code = fct_reorder(region_code, count)) |>
        filter(count >= 3 & !is.na(region_code)) 
      count_view = count_by_region |>
        ggplot(aes(x = region_code, y = count, fill = "tomato")) +
        geom_bar(stat = "identity") +
        labs(title = "Billionaire Count", x = "Region", y = "Count") +
        theme(axis.text.x = element_text(angle = -90, hjust = 1), legend.position = "none")
        
      ggplotly(count_view) |> print()
    })

    output$view1b <- renderPlotly({
      inter_data = bil_gdp |>
        filter(year == target_year & age >= target_age_range[1] & age <= target_age_range[2])

      count_by_gender = inter_data |>
        group_by(region_code, gender) |>
        summarise(gender_count = n(), .groups = "drop_last") |>
        left_join(count_by_region, by = join_by(region_code == region_code)) |>
        filter(count >= 3 & !is.na(region_code) ) |>
        mutate(prct = gender_count / count * 100) 

      gender_view = count_by_gender |>
        ggplot(aes(x = region_code, y = prct, fill = gender)) +
        geom_bar(stat = "identity") +
        scale_fill_manual(values = c("tomato", "lightblue", "grey"), 
                    labels = levels(count_by_gender$gender)) +
        labs(title = "Gender Distribution", x = "Region", y = "Precent") +
        theme(axis.text.x = element_text(angle = -90, hjust = 1))

      ggplotly(gender_view) |> print()
    })

    output$view1c <- renderPlotly({
      inter_data = bil_gdp |>
        filter(year == target_year & age >= target_age_range[1] & age <= target_age_range[2])

      count_by_self_made = inter_data |>
        group_by(region_code, self_made) |>
        summarise(self_made_count = n(), .groups = "drop_last") |>
        left_join(count_by_region, by = join_by(region_code == region_code)) |>
        filter(count >= 3 & !is.na(region_code) ) |>
        mutate(prct = self_made_count / count * 100) 
      self_made_view = count_by_self_made |>
        ggplot(aes(x = region_code, y = prct, fill = self_made)) +
        geom_bar(stat = "identity", alpha = .8) +
        scale_fill_manual(values = c("orange", "violet", "grey"), 
                    labels = levels(count_by_self_made$self_made)) +
        labs(title = "Self-made Distribution", x = "Region", y = "Precent") +
        theme(axis.text.x = element_text(angle = -90, hjust = 1))
    
      ggplotly(self_made_view) |> print()
    })

    output$view1d <- renderPlotly({
      inter_data = bil_gdp |>
        filter(year == target_year & age >= target_age_range[1] & age <= target_age_range[2])
        
      count_by_industries = inter_data |>
        group_by(region_code, industries) |>
        summarise(industries_count = n(), .groups = "drop_last") |>
        left_join(count_by_region, by = join_by(region_code == region_code)) |>
        filter(count >= 3 & !is.na(region_code) ) |>
        mutate(prct = industries_count / count * 100) 
      industries_view = count_by_industries |>
        ggplot(aes(x = region_code, y = prct, fill = industries)) +
        geom_bar(stat = "identity", alpha = .8) +
        labs(title = "Industry Distribution", x = "Region", y = "Precent") +
        theme(axis.text.x = element_text(angle = -90, hjust = 1)) 

      ggplotly(industries_view) |> print()
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
