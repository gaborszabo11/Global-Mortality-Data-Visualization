library(shiny)
library(tidyverse)
library(shinythemes)
library(gghighlight)
library(plotly)


# 1. LOAD AND CLEAN DATASET ----

mortality_tbl <- readr::read_csv("https://raw.githubusercontent.com/gaborszabo11/Global-Mortality-Data-Visualization/main/global_mortality.csv")


# Transform tibble (pivot longer, str_extract and str_trim)
mortality_tbl_long <- mortality_tbl %>% 
    
    # pivot tibble to long format
    pivot_longer(ends_with("(%)"), names_to = "cause", values_to = "proportion")


mortality_tbl_long <- mortality_tbl_long %>% 
    mutate(cause = str_extract(mortality_tbl_long$cause, "[^(%)]+")) %>% 
    mutate(cause = cause %>% str_trim()) %>% 
    mutate(proportion = proportion / 100)


# Countries vector
countries <- mortality_tbl_long %>% 
    distinct(country) %>% 
    pull()

# Causes vector
causes <- mortality_tbl_long %>% 
    distinct(cause) %>% 
    pull()





countries_continents_tbl <- readr::read_csv("https://raw.githubusercontent.com/gaborszabo11/Global-Mortality-Data-Visualization/main/countries_continents.csv")


mortality_tbl_long_continents <- mortality_tbl_long %>% 
    
    left_join(countries_continents_tbl, by = "country")



mortality_tbl_long_continents <- mortality_tbl_long_continents %>%
    mutate(continent = case_when(
        mortality_tbl_long_continents$country == "United States" ~ "North America",
        mortality_tbl_long_continents$country == "Bolivia" ~ "South America",
        mortality_tbl_long_continents$country == "Brunei" ~ "Asia",
        mortality_tbl_long_continents$country == "Cape Verde" ~ "Africa",
        mortality_tbl_long_continents$country == "Cote d'Ivoire" ~ "Africa",
        mortality_tbl_long_continents$country == "Czech Republic" ~ "Europe",
        mortality_tbl_long_continents$country == "Democratic Republic of Congo" ~ "Africa",
        mortality_tbl_long_continents$country == "England" ~ "Europe",
        mortality_tbl_long_continents$country == "Iran" ~ "Asia",
        mortality_tbl_long_continents$country == "Laos" ~ "Asia",
        mortality_tbl_long_continents$country == "Macedonia" ~ "Europe",
        mortality_tbl_long_continents$country == "Micronesia (country)" ~ "Oceania",
        mortality_tbl_long_continents$country == "Moldova" ~ "Europe",
        mortality_tbl_long_continents$country == "North Korea" ~ "Asia",
        mortality_tbl_long_continents$country == "Northern Ireland" ~ "Europe",
        mortality_tbl_long_continents$country == "Palestine" ~ "Asia",
        mortality_tbl_long_continents$country == "Russia" ~ "Asia",
        mortality_tbl_long_continents$country == "Scotland" ~ "Europe",
        mortality_tbl_long_continents$country == "South Korea" ~ "Asia",
        mortality_tbl_long_continents$country == "Swaziland" ~ "Africa",
        mortality_tbl_long_continents$country == "Syria" ~ "Asia",
        mortality_tbl_long_continents$country == "Taiwan" ~ "Asia",
        mortality_tbl_long_continents$country == "Tanzania" ~ "Africa",
        mortality_tbl_long_continents$country == "Timor" ~ "Asia",
        mortality_tbl_long_continents$country == "United Kingdom" ~ "Europe",
        mortality_tbl_long_continents$country == "Venezuela" ~ "South America",
        mortality_tbl_long_continents$country == "Vietnam" ~ "Asia",
        mortality_tbl_long_continents$country == "Wales" ~ "Europe",
        TRUE                                                     ~ mortality_tbl_long_continents$continent)
    )





# 2. UI ----
ui <- navbarPage("Global Mortality Data App",
    
    theme = shinytheme("cosmo"),
    
    # Tab 1 ----
    tabPanel("B/w countries by cause",

    fluidRow(
        
        # first column
        column(5,
               hr(),
               sidebarPanel(width = 6,
                            
                            selectInput(inputId = "country",
                                     label      = "Select countries/regions", 
                                     choices    = countries, 
                                     selected   = c("United States", "Canada", "Hungary", "Italy", "Japan", "China"), 
                                     multiple   = TRUE, 
                                     selectize  = FALSE,
                                     size = 30)
                ),
            
            sidebarPanel(width = 6,
                         
                         selectInput(inputId    = "cause",
                                     label      = "Select cause", 
                                     choices    = causes, 
                                     selected   = "Cancers", 
                                     multiple   = FALSE, 
                                     selectize  = FALSE,
                                     size = 30)
            )
            ),

        # second column
        column(6, 
               offset = 0,
               
               # small multiples plot
               plotOutput("small_multiples",
                          width = "800px",
                          height = "660px")
               
        )
    )
),

    # Tab 2 ----
    tabPanel("B/w countries vs. rest of the world by cause",
             
             fluidRow(
                 
                 # first column
                 column(5,
                        hr(),
                        sidebarPanel(width = 6,
                                     
                                     selectInput(inputId = "country_2",
                                                 label      = "Select countries/regions", 
                                                 choices    = countries, 
                                                 selected   = c("United States", "Canada", "Hungary", "Italy", "Japan", "China"), 
                                                 multiple   = TRUE, 
                                                 selectize  = FALSE,
                                                 size = 30)
                        ),
                        
                        sidebarPanel(width = 6,
                                     
                                     selectInput(inputId    = "cause_2",
                                                 label      = "Select cause", 
                                                 choices    = causes, 
                                                 selected   = "Cancers", 
                                                 multiple   = FALSE, 
                                                 selectize  = FALSE,
                                                 size = 30)
                        )
                 ),
                 
                 # second column
                 column(6, 
                        offset = 0,
                        
                        # plot
                        plotOutput("btw_countries_by_cause",
                                   width  = "800px",
                                   height = "400px",
                                   brush = brushOpts(id         = "btw_countries_by_cause_brush",
                                                     resetOnNew = TRUE
                                                     )
                        ),
                        plotOutput("btw_countries_by_cause_zoom",
                                   width  = "800px",
                                   height = "300px")
                        
                 )
             )
    ),


    # Tab 3 ----
    tabPanel("B/w causes vs. rest of the causes by country",
             
             fluidRow(
                 
                 # first column
                 column(5,
                        hr(),
                        sidebarPanel(width = 6,
                                     
                                     selectInput(inputId = "country_3",
                                                 label      = "Select country", 
                                                 choices    = countries, 
                                                 selected   = c("United States", "Canada", "Hungary", "Italy", "Japan", "China"), 
                                                 multiple   = FALSE, 
                                                 selectize  = FALSE,
                                                 size = 30)
                        ),
                        
                        sidebarPanel(width = 6,
                                     
                                     selectInput(inputId    = "cause_3",
                                                 label      = "Select causes", 
                                                 choices    = causes, 
                                                 selected   = c("Cardiovascular diseases", "Cancers"), 
                                                 multiple   = TRUE, 
                                                 selectize  = FALSE,
                                                 size = 30)
                        )
                 ),
                 
                 # second column
                 column(6, 
                        offset = 0,
                        
                        # plot
                        plotOutput("btw_cause_by_country",
                                   width  = "800px",
                                   height = "400px",
                                   brush = brushOpts(id         = "btw_cause_by_country_brush",
                                                     resetOnNew = TRUE
                                                     )
                        ),
                        plotOutput("btw_cause_by_country_zoom",
                                   width  = "800px",
                                   height = "300px")
                        
                 )
             )
    ),

    # Tab 4 ----
    tabPanel("Pareto of causes by country",
         
            fluidRow(
             
                # first column
                column(5,
                        hr(),
                        sidebarPanel(width = 6,
                                    selectInput(inputId    = "country_4",
                                                label      = "Select country", 
                                                choices    = countries, 
                                                selected   = c("United States"), 
                                                multiple   = FALSE, 
                                                selectize  = FALSE,
                                                size = 30
                                                )
                                    ),
                       
                       
                        sidebarPanel(width = 6,
                                    sliderInput(inputId = "year_range", 
                                                label   = "Date range:",
                                                min     = 1990, 
                                                max     = 2016,
                                                value   = c(1990, 2016),
                                                sep     = ""
                                                )
                                    )
                                    
                ),
             
                # second column
                column(7, 
                    offset = 0,
                    
                    # plot
                    plotOutput("pareto",
                               width  = "800px",
                               height = "650px"),
                    
                        )
                
        )
    ),

    # Tab 5 ----
    tabPanel("Relative change by country by continent",
    
         
            fluidRow(
                
                
             
                # first column
                column(5,
                        hr(),
                        sidebarPanel(width = 6,
                                    selectInput(inputId    = "cause_4",
                                             label      = "Select cause", 
                                             choices    = causes, 
                                             selected   = c("Cancers"), 
                                             multiple   = FALSE, 
                                             selectize  = FALSE,
                                             size = 30
                                 )
                    )
                    
             ),
             
                # second column
                column(7, 
                        offset = 0,
             
                        # plot
                        plotlyOutput("relative_change_plot",
                            width  = "800px",
                            height = "650px")
                )
             
            )

             
         )
)





# 3. SERVER ----
server <- function(input, output) {
    

# Small multiples function and plot ----    
    create_small_multiples <- function(countries, cause_of_death) {
        
        mortality_tbl_long %>% 
            
            filter(country %in% countries) %>%
            filter(cause == cause_of_death) %>%
            
            mutate(country = as_factor(country) %>% fct_reorder(proportion, .fun = mean, .desc = TRUE)) %>% 
            
            ggplot(aes(x = year, y = proportion)) +
            
            geom_line(aes(group = cause), color ="grey", size = 0.9) +
            
            facet_wrap(~ country, ncol = 4) +
            
            theme_light() +
            theme(
                panel.grid.major = element_blank(),
                panel.grid.minor = element_blank(),
                axis.title       = element_text(color = "grey30", size = 10),
                axis.text        = element_text(color = "grey30", size = 10),
                strip.background = element_rect(fill = "#cfd8e6"),
                strip.text       = element_text(colour = "grey30", size = 13),
                plot.title    = element_text(size = 20, face = "bold", color = "grey30"),
                plot.subtitle = element_text(size = 15, face = "bold", color = "grey30")
                ) +
            coord_cartesian(ylim = c(0, NA)) +
            labs(
                title    = "Comparison Between Countries/Regions - Small Multiples Plot", 
                subtitle = input$cause, 
                x        = "", 
                y        = "Proportion (% of overall deaths)") +
            scale_x_continuous(breaks = c(1990, 1995, 2000, 2005, 2010, 2015)) +
            scale_y_continuous(labels = scales::percent_format())
        
    }
    

    output$small_multiples <- renderPlot({
        
        
        create_small_multiples(input$country, input$cause)
        
        
    })
 

    
    
# Between countries vs. rest of the world function and plot ----
    
    # range variable for secondary plot for zooming
    ranges2 <- reactiveValues(x = NULL, y = NULL)
    
    
    output$btw_countries_by_cause <- renderPlot({
        
        
        mortality_tbl_long %>% 
            
            filter(cause == input$cause_2) %>% 
            
            
            ggplot(aes(x = year, y = proportion, color = country)) +
            
            geom_line() +
            gghighlight(country %in% input$country_2,
                        unhighlighted_params = list(size = 1, colour = alpha("lightgrey", 0.2))) +
            
            theme_light() +
            theme(panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(),
                  axis.title       = element_text(color = "grey30", size = 10),
                  axis.text        = element_text(color = "grey30", size = 10),
                  plot.title       = element_text(size = 20, face = "bold", color = "grey30"),
                  plot.subtitle    = element_text(size = 15, face = "bold", color = "grey30"),
                  plot.caption     = element_text(color = "grey30", size = 12, hjust = 0.5)
            ) +
            labs(
                title    = "Comparison Between Countries/Regions vs. Rest of The World by Cause",
                subtitle = input$cause_2,
                x        = "", 
                y        = "Proportion (% of overall deaths)",
                caption = "Select a specific part of the upper plot to zoom in on relevant details and have it displayed in the lower plot") +
            scale_x_continuous(breaks = c(1990, 1995, 2000, 2005, 2010, 2015)) +
            scale_y_continuous(labels = scales::percent_format()) +
            scale_color_brewer(palette = "Dark2")
        
    })
    
    
    output$btw_countries_by_cause_zoom <-  renderPlot({
        
        mortality_tbl_long %>% 
            
            filter(cause == input$cause_2) %>% 
            
            
            ggplot(aes(x = year, y = proportion, color = country)) +
            
            geom_line() +
            gghighlight(country %in% input$country_2,
                        unhighlighted_params = list(size = 1, colour = alpha("lightgrey", 0.2))) +
            
            theme_light() +
            theme(panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(),
                  axis.title       = element_text(color = "grey30")
            ) +
            labs(
                x        = "", 
                y        = "Proportion (% of overall deaths)") +
            scale_x_continuous(breaks = c(1990, 1995, 2000, 2005, 2010, 2015)) +
            scale_y_continuous(labels = scales::percent_format()) +
            scale_color_brewer(palette = "Dark2") +
            
            coord_cartesian(xlim = ranges2$x, ylim = ranges2$y, expand = FALSE)
        
    })
    
    
    # When a double-click happens, check if there's a brush on the plot.
    # If so, zoom to the brush bounds; if not, reset the zoom.
    observe({
        brush <- input$btw_countries_by_cause_brush
        if (!is.null(brush)) {
            ranges2$x <- c(brush$xmin, brush$xmax)
            ranges2$y <- c(brush$ymin, brush$ymax)
            
        } else {
            ranges2$x <- NULL
            ranges2$y <- NULL
        }
    })
    
    
    
    
    
    
   
# Between selected causes vs. rest of causes by country function and plot ----   
    

    # range variable for secondary plot for zooming
    ranges3 <- reactiveValues(x = NULL, y = NULL)   
    
    
    
    output$btw_cause_by_country <- renderPlot({
        
        mortality_tbl_long %>% 
            
            filter(country == input$country_3) %>% 
            
            ggplot(aes(x = year, y = proportion)) +
            
            geom_line(aes(group = cause, color = cause)) +
            gghighlight(cause %in% input$cause_3,
                        unhighlighted_params = list(size = 1, colour = alpha("grey", 0.24))) +
            
            theme_light() +
            theme(panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(),
                  axis.title       = element_text(color = "grey30", size = 10),
                  axis.text        = element_text(color = "grey30", size = 10),
                  plot.title       = element_text(size = 20, face = "bold", color = "grey30"),
                  plot.subtitle    = element_text(size = 15, face = "bold", color = "grey30"),
                  plot.caption     = element_text(color = "grey30", size = 12, hjust = 0.5)
            ) +
            labs(
                title    = "Comparison Between Selected Causes vs. Rest of The Causes by Country/Region",
                subtitle = input$country_3,
                x        = "", 
                y        = "Proportion (% of overall deaths)",
                caption  = "Select a specific part of the upper plot to zoom in on relevant details and have it displayed in the lower plot") +
            scale_x_continuous(breaks = c(1990, 1995, 2000, 2005, 2010, 2015)) +
            scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
            scale_color_brewer(palette = "Dark2")
        
    })
    
   
    
    output$btw_cause_by_country_zoom <- renderPlot({
        
        mortality_tbl_long %>% 
            
            filter(country == input$country_3) %>% 
            
            ggplot(aes(x = year, y = proportion)) +
            
            geom_line(aes(group = cause, color = cause)) +
            gghighlight(cause %in% input$cause_3,
                        unhighlighted_params = list(size = 1, colour = alpha("grey", 0.24))) +
            
            theme_light() +
            theme(panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(),
                  axis.title       = element_text(color = "grey30")
            ) +
            labs(
                x        = "", 
                y        = "Proportion (% of overall deaths)"
                ) +
            scale_x_continuous(breaks = c(1990, 1995, 2000, 2005, 2010, 2015)) +
            scale_y_continuous(labels = scales::percent_format()) +
            scale_color_brewer(palette = "Dark2") +
            
            coord_cartesian(xlim = ranges3$x, ylim = ranges3$y, expand = FALSE)
        
    }) 
    
    
    # When a double-click happens, check if there's a brush on the plot.
    # If so, zoom to the brush bounds; if not, reset the zoom.
    observe({
        brush <- input$btw_cause_by_country_brush
        if (!is.null(brush)) {
            ranges3$x <- c(brush$xmin, brush$xmax)
            ranges3$y <- c(brush$ymin, brush$ymax)
            
        } else {
            ranges3$x <- NULL
            ranges3$y <- NULL
        }
    })


    
    
# Pareto ----    
    
    output$pareto <- renderPlot({
        
        mortality_tbl_long %>% 
            
            filter(country == input$country_4) %>% 
            filter(year >= range(input$year_range)[1] & year <= range(input$year_range)[2]) %>%
            filter(!is.na(proportion)) %>% 
            
            group_by(cause) %>% 
            summarize(proportion = mean(proportion, na.rm = TRUE)) %>% 
            ungroup() %>%
            
            mutate(cause = cause %>% as_factor() %>% fct_reorder(proportion)) %>% 
            mutate(cause_fct_num = cause %>% as_factor() %>% fct_reorder(desc(proportion)) %>% as.numeric()) %>%  
            
            mutate(category = case_when(cause_fct_num < 4 ~ "top 3",
                                        cause_fct_num < 11 ~ "top 10",
                                        TRUE ~ "the rest") %>% as_factor() %>% fct_reorder(desc(cause_fct_num))) %>% 
            
            ggplot(aes(cause, proportion)) +
            geom_col(aes(fill = category)) +
            geom_text(aes(label = proportion %>% scales::percent(accuracy = 0.01)),
                      position = position_dodge(width = 0.2),
                      hjust = -0.2, 
                      size = 4, 
                      color = "grey30"
                      ) +
            coord_flip() +
            
            theme_light() +
            theme(panel.grid.major.y = element_blank(),
                  panel.grid.minor   = element_blank(),
                  axis.title         = element_text(color = "grey30", size = 10),
                  axis.text          = element_text(color = "grey30", size = 10),
                  plot.title         = element_text(size = 20, face = "bold", color = "grey30"),
                  plot.subtitle      = element_text(size = 15, face = "bold", color = "grey30"),
                  legend.text        = element_text(size = 11, color = "grey30"),
                  legend.title       = element_text(size = 13, color = "grey30")
            ) +
            labs(
                title    = "Pareto Chart of Causes by Country/Region",
                subtitle = case_when(
                    range(input$year_range)[1] == range(input$year_range)[2] ~ str_glue("{input$country_4} ({range(input$year_range)[1]})"),
                    TRUE ~ str_glue("{input$country_4} ({range(input$year_range)[1]}-{range(input$year_range)[2]})")
                ),
                x        = "Cause", 
                y        = "Proportion (% of overall deaths)") +
            guides(fill = guide_legend(reverse = TRUE)) +
            scale_y_continuous(
                labels = scales::percent_format(accuracy = 1),
                breaks = seq(0, 1, by = 0.1),
                limits = c(0, 0.65)
                ) +
            scale_fill_brewer(palette = "Blues")
        
        
        
    })

    
    
# Relative change plot ----
    
    output$relative_change_plot <- renderPlotly({
        
        plot <- mortality_tbl_long_continents %>%
            
            filter(!is.na(continent)) %>% 
            
            mutate(country   = as_factor(country)) %>%
            mutate(continent = as_factor(continent)) %>% 
            filter(year == 1990 | year == 2016) %>% 
            
            group_by(country, cause) %>% 
            arrange(country, cause) %>% 
            
            mutate(lag        = lag(proportion)) %>% 
            mutate(change     = (proportion / lag) - 1) %>% 
            mutate(change_pct = change %>% scales::percent(accuracy = 0.01)) %>%
            
            ungroup() %>% 
            
            filter(!is.na(lag)) %>% 
            
            filter(cause == input$cause_4) %>% 
            
            select(country, year, cause, proportion, continent, change) %>% 
            
            mutate(text_label = str_glue("{country}
                                 {change %>% scales::percent(accuracy = 0.1)}")) %>% 
            
            ggplot(aes(continent, change)) +
            geom_jitter(aes(text = text_label), color = "#08519C", width = 0.15, size = 1, alpha = 0.75) +
            scale_y_continuous(labels = scales::percent) +
            theme_light() +
            theme(
                panel.grid.major.x = element_blank(),
                panel.grid.minor   = element_blank(),
                axis.title         = element_text(color = "grey30", size = 10),
                axis.text          = element_text(color = "grey30", size = 10)) +
            labs(
                title = str_glue("Relative change in proportion of deaths for {input$cause_4} between 1990-2016"),
                x = "",
                y = "Relative change"
            )
        
        
        ggplotly(plot, tooltip = "text") %>% 
            layout(margin = list(t = 25))
        
        
    })
    
    
    }


   




# 4. RUN APPLICATION ----
shinyApp(ui = ui, server = server)


