library(shinythemes)




navbarPage( theme = shinytheme("darkly"),
            "ATP match results 2013-2023",
           # adding that custom CSS
           tags$head(
             tags$link(rel = "stylesheet", type = "text/css", href = "font_change.css")
           ),       
  
  # tab title
  tabPanel("Word Cloud",
  
    sidebarLayout(
      # Sidebar with a slider and selection inputs
      sidebarPanel(
        selectInput("selection", "Choose a category:",
                    choices = selections),
        actionButton("update", "Change"),
        hr(),
        sliderInput("max",
                    "Maximum Number of Words:",
                    min = 1,  max = 300,  value = 100),
        sliderInput("size",
                    "Maximum Size of Words:",
                    min = 1,  max = 20,  value = 10)
      ),
      
      # Show Word Cloud
      mainPanel(
        plotOutput("wordcloud")
      )
    )
  ),# end of word cloud
  
  tabPanel("Histogram",
           sidebarPanel(
                selectInput(inputId = "n_breaks",
                            label = "Number of bins in histogram (approximate):",
                            choices = c(10, 20, 35, 50),
                            selected = 20),
                
                checkboxInput(inputId = "individual_obs",
                              label = strong("Show individual observations"),
                              value = FALSE),
                
                checkboxInput(inputId = "density",
                              label = strong("Show density estimate"),
                              value = FALSE),
           ),
           mainPanel(
                plotOutput(outputId = "histogram", height = "300px"),
                
                # Display this only if the density is shown
                conditionalPanel(condition = "input.density == true",
                                 sliderInput(inputId = "bw_adjust",
                                             label = "Bandwidth adjustment:",
                                             min = 0.2, max = 2, value = 1, step = 0.2)
                )
           )
                
  ), # end of histogram
  
  tabPanel("Player ranking over time",
           sidebarPanel(
             selectInput(inputId = "players",
                         label = "Player",
                         choices = player_selections$name,
                         selected = "Djokovic N."),
           ),
           mainPanel(
             plotOutput(outputId = "rank_trends", height = "300px"),
           )
           
  ) #end or line plot
  
)

