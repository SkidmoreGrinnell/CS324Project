library(shinythemes)




navbarPage( theme = shinytheme("darkly"),
            "ATP match results 2013-2023",
           # adding that custom CSS to make the title look fun
           tags$head(
             tags$link(rel = "stylesheet", type = "text/css", href = "font_change.css")
           ),  
  # Home panel for introduction
  tabPanel("Home",
           h2("Welcome to my app \"ATP match results 2013-2023\""),
           tags$pre(p("This app visualizes the last 10 years of results from the ATP or\nAmerican Tennis Professional tour. You are welcome to browse:\n\n
           The Word Cloud 
             where you can find the most prolific players and the largest tournaments
             
           The Histogram where you can find out
             the rankings of the people most commonly accepted into ATP tournaments
           
           The Player rankings over time
              where you can select one or many players and look at their respective rankings
           
           Who Played Who 
              where you can see what players have played each other at particular tournaments
             \n\n-Spencer Skidmore"))
           
           ),
  # Word Cloud Panel
  tabPanel("Word Cloud",
  
    sidebarLayout(
      sidebarPanel(
        # select players or tournament names
        selectInput("selection", "Tournaments or Players:",
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
                            choices = c(10, 20, 35, 50, 70, 100, 200),
                            selected = 20),
                sliderInput(inputId = "max_ranking",
                            label = "Maximum ranking of players displayed:",
                            min = 250, max = 2500, value = 2250, step = 250),
                
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
             # selects using a text and click input
             selectizeInput(inputId = "players",
                            label = "Choose a player:",
                            choices = player_selections,
                            multiple = TRUE, 
                            selected = "Djokovic N."
             )
             
           ),
           mainPanel(
             plotlyOutput(outputId = "rank_trends", height = "300px"),
           )
           
  ), #end or line plot
  
  tabPanel("Who Played Who",
           # https://stackoverflow.com/questions/62716572/selectinput-category-selection
           # Stéphane Laurent's answer
           # slightly modified for my data
           selectizeInput(inputId = "network_player",
                          label = "Choose a player:",
                          choices = player_selections,
                          multiple = FALSE
           ),
           
           
           selectizeInput(inputId = "network_tournament",
                          label = "Choose a tournament:",
                          choices = new_tournaments,
                          multiple = FALSE,
           ),
           mainPanel(
             #show network graph
             plotlyOutput(outputId = "network", width = Inf),
           )
           
  )
  
)

