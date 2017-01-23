library(shiny)
library(ggplot2)
library(mice)

set.seed(67)
sledzie <-read.csv("sledzie.csv", sep = ",", na.strings = "?", header = TRUE)
sledzie <- mice(sledzie, m=1, method='mean', seed=67, echo=FALSE)
sledzie <- complete(sledzie, 1)

ui <- basicPage(theme = "bootstrap.css",
  tags$div(
    HTML("<div class='list-group'><button type='button' class='list-group-item list-group-item-action active'>Instrukcja</button><button type='button' class='list-group-item list-group-item-action'>1. Zaznacz interesujacy Cie obszar</button><button type='button' class='list-group-item list-group-item-action'>2. Dwuklik na zaznaczeniu, aby zblizyc</button><button type='button' class='list-group-item list-group-item-action'>3. Dwuklik bez zanaczenia, aby oddalic</button></div>")
  ),
  plotOutput("plot1",
             dblclick = "plot1_dblclick",
             brush = brushOpts(
               id = "plot1_brush",
               resetOnNew = TRUE
             )
  )
)

server <- function(input, output) {
  ranges <- reactiveValues(x = NULL, y = NULL)
  
  output$plot1 <- renderPlot({
    ggplot(sledzie, aes(x=X, y=length)) + 
      geom_smooth(size=2) + 
      geom_point(size = 0.01) + 
      labs(
        title = "Zmiana rozmiaru sledzia w czasie", 
        x = "Czas", 
        y = "Rozmiar sledzia [cm]") +
      theme_bw() + 
      coord_cartesian(xlim = ranges$x, ylim = ranges$y)
  })
  
  observeEvent(input$plot1_dblclick, {
    brush <- input$plot1_brush
    if (!is.null(brush)) {
      ranges$x <- c(brush$xmin, brush$xmax)
      ranges$y <- c(brush$ymin, brush$ymax)
      
    } else {
      ranges$x <- NULL
      ranges$y <- NULL
    }
  })
}

shinyApp(ui, server)