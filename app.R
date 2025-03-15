library(tidyverse)
library(shiny)
library(bslib)
library(bsicons)
library(gt)
library(tidyquant)
library(usethis)

# Define UI for application that draws a histogram
ui <- page_navbar(
    
    title = "Broker Platform",
    
    nav_panel(
        title = "Exchange",
        layout_sidebar(
            sidebar = sidebar(
                selectizeInput(
                    inputId = "select_exchange",
                    label = "Select Exchange",
                    choices = tq_exchange_options(),
                    selected = tq_exchange_options()[2],
                    multiple = FALSE
                ),
                actionButton(
                    inputId = "submit_exchange",
                    label = "Submit"
                )
            ),
            render_gt("exchange_table"),
            render_gt("stock_exchange_table"),
        ),
        
    ),
    
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    exchange_data <- eventReactive(input$submit_exchange, {
        tq_exchange(input$select_exchange)
    })
    output$exchange_table <- render_gt(
        exchange_data() |> 
            gt() |> 
            opt_interactive()
    )
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
