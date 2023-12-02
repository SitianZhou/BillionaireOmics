#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

source("./utils.R")

theme_set(
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5),
        text = element_text(family = "Helvetica")
  )
)

# Define server logic required to draw a histogram
function(input, output, session) {

    ################## map dashboard ##################
    gdp_viz = reactive({
        year_selection(input$mapYear)
    })

    bil_viz = reactive({
        billionaire_marker(input$mapYear)
    })

    output$map <- renderLeaflet({
      leaflet() |>
        addProviderTiles("CartoDB.Positron") |>  # You can choose different tile providers
        addPolygons(data = gdp_viz(), 
                    fillColor = ~colorQuantile("YlOrRd", gdp)(gdp), 
                    fillOpacity = 0.3, color = "white", weight = 1,
                    label = ~paste("GDP: ", round(gdp, 3), " trillion"),
                    highlightOptions = highlightOptions(
                      color = "black", weight = 2, bringToFront = TRUE)) |>
        addMarkers(data = bil_viz(),
                  label = ~paste("Region: ", country_of_citizenship),
                  popup = ~info
        ) |>
        setView(lng = 0, lat = 30, zoom = 2) 
    })

    output$mapTable <- renderDT({
        datatable(bil_viz(),
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

    
    ################## view1 ##################

    target_year = reactive({
      input$view1Year
    })

    target_age = reactive({
      input$view1Age
    })

    inter_data = reactive({
      bil_gdp |>
        filter(year == target_year() & age >= target_age()[1] & age <= target_age()[2])
    })

    region_data = reactive({
      inter_data() |>
        group_by(region_code) |>
        summarise(count = n()) |>
        mutate(region_code = fct_reorder(region_code, count)) |>
        filter(count >= 3 & !is.na(region_code))
    })

    output$view1a <- renderPlotly({
      count_view = region_data() |>
        ggplot(aes(x = region_code, y = count, fill = "tomato")) +
        geom_bar(stat = "identity") +
        labs(title = "Billionaire Count", x = "Region", y = "Count") +
        theme(axis.text.x = element_text(angle = -90, hjust = 1), legend.position = "none")
        
      ggplotly(count_view) |> print()
    })

    output$view1b <- renderPlotly({
      gender_view = inter_data() |>
        group_by(region_code, gender) |>
        summarise(gender_count = n(), .groups = "drop_last") |>
        left_join(region_data(), by = join_by(region_code == region_code)) |>
        filter(count >= 3 & !is.na(region_code) ) |>
        mutate(prct = gender_count / count * 100) |>
        ggplot(aes(x = region_code, y = prct, fill = gender)) +
        geom_bar(stat = "identity") +
        scale_fill_manual(values = c("tomato", "lightblue", "grey")) +
        labs(title = "Gender Distribution", x = "Region", y = "Precent") +
        theme(axis.text.x = element_text(angle = -90, hjust = 1))

      ggplotly(gender_view) 
    })

    output$view1c <- renderPlotly({
      self_made_view = inter_data() |>
        group_by(region_code, self_made) |>
        summarise(self_made_count = n(), .groups = "drop_last") |>
        left_join(region_data(), by = join_by(region_code == region_code)) |>
        filter(count >= 3 & !is.na(region_code) ) |>
        mutate(prct = self_made_count / count * 100) |>
        ggplot(aes(x = region_code, y = prct, fill = self_made)) +
        geom_bar(stat = "identity", alpha = .8) +
        scale_fill_manual(values = c("orange", "violet", "grey")) +
        labs(title = "Self-made Distribution", x = "Region", y = "Precent") +
        theme(axis.text.x = element_text(angle = -90, hjust = 1))
      ggplotly(self_made_view) 
    })

    output$view1d <- renderPlotly({
      industries_view = inter_data() |>
        group_by(region_code, industries) |>
        summarise(industries_count = n(), .groups = "drop_last") |>
        left_join(region_data(), by = join_by(region_code == region_code)) |>
        filter(count >= 3 & !is.na(region_code) ) |>
        mutate(prct = industries_count / count * 100) |>
        ggplot(aes(x = region_code, y = prct, fill = industries)) +
        geom_bar(stat = "identity", alpha = .8) +
        labs(title = "Industry Distribution", x = "Region", y = "Precent") +
        theme(axis.text.x = element_text(angle = -90, hjust = 1), 
          legend.text = element_text(size = 8), legend.position = "top") +
        viridis::scale_fill_viridis(
          name = "industries", 
          discrete = TRUE,
          option = "H"
        )
      ggplotly(industries_view) 
    })

    ################## view2 ##################

    target_year = reactive({
      input$view2Year
    })
    code = reactive({
      map(input$view2Region, extract_code)
    })

    rnk_thres = reactive({
      input$view2Rank
    })

    region_select_all = reactive({
      bil_gdp |> 
        filter(region_code %in% code())
    })

    region_select = reactive({
      region_select_all() |>
        filter(year == target_year())
    })
    
    output$view2a <- renderPlotly({
      region_select_all() |>
        select(year, region_gdp, region_code) |>
        mutate(region_code = fct_reorder(region_code, region_gdp)) |>
        distinct() |>
        ggplot(aes(x = year, y = region_gdp, color = region_code)) +
        geom_line() +
        geom_point() +
        labs(x = "Year", y = "GDP(Billion)", title = "GDP in recent years") 
    })

    output$view2b <- renderPlotly({
      low = rnk_thres()[1]
      high = rnk_thres()[2]

      rnk_bar = region_select() |>
        mutate(region_code = fct_reorder(region_code, region_gdp)) |>
        group_by(region_code) |>
        arrange(desc(net_worth)) |>  # Arrange in descending order based on 'value'
        mutate(rnk = row_number()) |>  # Add rank labels
        filter(rnk <= high & rnk >= low) |>  # Select top 10 values
        select(region_code, net_worth, full_name, rnk) |>
        ggplot(aes(x = rnk, y = net_worth, fill = region_code, label = full_name)) +
        geom_bar(stat = "identity", position = "dodge", color = "white") +
        scale_x_continuous(breaks = seq(low, high, by = 1)) +
        labs(x = "Rank", y = "Wealth (Billion)", title = "Wealth comparison") +
        theme(legend.position = "none") 
      ggplotly(rnk_bar)
    })

    output$view2c <- renderPlotly({
      histo = region_select() |>
        mutate(region_code = fct_reorder(region_code, region_gdp)) |>
        ggplot(aes(x = age, fill = region_code)) +
        geom_histogram(binwidth = 2) +
        facet_grid(region_code ~ .) + 
        theme(legend.position = "none")
      ggplotly(histo)
    })

    ################## db ##################
    output$datatable <- renderDT({
        datatable(bil_gdp,
                  filter = "top",
                  selection = list(target = 'column'),
                  options = list(
                    pageLength = 10,
                    scrollX = TRUE,
                    # buttons = c('copy', 'csv', 'excel', 'print', 'colvis'),
                    columnDefs = list(list(
                        searchPanes = list(show = FALSE), targets = 1:4
                        ))
                  )
        )
    })

}
