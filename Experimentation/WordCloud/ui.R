library(shinythemes)




fluidPage( theme = shinytheme("darkly"),
           # adding that custom CSS
           tags$head(
             tags$link(rel = "stylesheet", type = "text/css", href = "font_change.css")
           ),       
  
  # Application title
  titlePanel("Word Cloud"),
  
  sidebarLayout(
    # Sidebar with a slider and selection inputs
    sidebarPanel(
      selectInput("selection", "Choose a book:",
                  choices = selections),
      actionButton("update", "Change"),
      hr(),
      sliderInput("freq",
                  "Minimum Frequency:",
                  min = 30,  max = 100, value = 15),
      sliderInput("max",
                  "Maximum Number of Words:",
                  min = 1,  max = 300,  value = 100),
      sliderInput("size",
                  "Maximum Size of Words:",
                  min = 1,  max = 300,  value = 100)
    ),
    
    # Show Word Cloud
    mainPanel(
      plotOutput("plot")
    )
  )
)

