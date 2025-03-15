source("global.R")

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
                ),
                selectizeInput(
                    inputId = "select_stock_exchange",
                    label = "Select Stock from Exchange",
                    choices = NULL,
                    selected = NULL,
                    multiple = TRUE
                ),
                actionButton(
                    inputId = "submit_stock_exchange",
                    label = "Submit"
                ),
            ),
            gt_output("exchange_table"),
            gt_output("stock_exchange_table"),
        ),
        
    ),
    
    
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
    
    ### PAGE 1 ###
    selected_exchange <- reactiveVal(NULL)
    stocks_list <- reactiveVal(NULL)
    
    # EXCHANGE
    exchange_data <- eventReactive(input$submit_exchange, {
        req(input$select_exchange)
        selected_exchange(input$select_exchange)
        data <- tq_exchange(input$select_exchange)
        stocks_list(data$symbol)
        data
    })
    # update exchange stock selection
    observeEvent(input$submit_exchange, {
        updateSelectizeInput(
            session,
            inputId = "select_stock_exchange",
            choices = stocks_list(),
            server = TRUE
            )
    })
    # render exchange data
    output$exchange_table <- render_gt({
        req(exchange_data())
        exchange_data() |> 
            gt() |> 
            opt_interactive()
    })
    ### PAGE 2 - STOCK DATA ###
    stock_data <- eventReactive(input$submit_stock_exchange, {
        req(input$select_stock_exchange)
        tq_get(input$select_stock_exchange, from = Sys.Date() - 1, to = Sys.Date())
    })
    
    # Render stock table
    output$stock_exchange_table <- render_gt({
        req(stock_data())
        stock_data() |> 
            gt() |> 
            opt_interactive()
    })
    
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
