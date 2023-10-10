library(shinythemes)




navbarPage( theme = shinytheme("darkly"),
            "ATP match results 2013-2023",
            # adding that custom CSS to make the title look fun
            tags$head(
              tags$link(rel = "stylesheet", type = "text/css", href = "font_change.css")
            ),  
            
            
            
            ### HOME PANEL ###
            tabPanel("Home",
                     h2("Welcome to my app \"ATP match results 2013-2023\""),
                     tags$pre(p("This app visualizes the last 10 years of results from the ATP or\nAmerican Tennis Professional tour. You are welcome to browse:\n\n
           The Word Cloud 
             where you can find the most prolific players and the largest tournaments
             here I have an additional data set with 2000-2014 results
             
           The Histogram where you can find out
             the rankings of the people most commonly accepted into ATP tournaments
           
           The Player rankings over time
              where you can select one or many players and look at their respective rankings
           
           Who Played Who 
              where you can see what players have played each other at particular tournaments
             \n\n-Spencer Skidmore"))
                     
            ),
            
            
            ### WORD CLOUD ###
            tabPanel("Word Cloud",
                     h2("Biggest Tournaments and Tournaments in the ATP Tour"),
                     sidebarLayout(
                       sidebarPanel(
                         
                         # select players or tournament names
                         selectInput("selection", "Tournaments or Players:",
                                     choices = selections),
                         actionButton("update", "Change"),
                         hr(),
                         
                         # select how many name can be seen
                         sliderInput("max",
                                     "Maximum number of names:",
                                     min = 1,  max = 300,  value = 100),
                         
                         # select how big the word cloud is
                         sliderInput("size",
                                     "Change size:",
                                     min = 1,  max = 20,  value = 10)
                       ),
                       
                       # Show Word Cloud
                       mainPanel(
                         plotOutput("wordcloud")
                       )
                     )
            ),# end of word cloud
            
            
            ### HISTOGRAM ###
            tabPanel("Histogram",
                     h2("What Ranks get to Play in ATP Tournaments"),
                     sidebarPanel(
                       
                       # choose how many bins
                       selectInput(inputId = "n_breaks",
                                   label = "Number of bins in histogram (approximate):",
                                   choices = c(10, 20, 35, 50, 70, 100, 200),
                                   selected = 20),
                       
                       # change the max value on the x-axis (aka ranking)
                       sliderInput(inputId = "max_ranking",
                                   label = "Maximum ranking of players displayed:",
                                   min = 250, max = 2500, value = 2250, step = 250),
                       
                       # check to show datapoints laid out along the x-axis
                       checkboxInput(inputId = "individual_obs",
                                     label = strong("Show individual observations"),
                                     value = FALSE),
                       
                       # check to show a density curve of the results
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
            
            
            ### PLAYER RANKING OVER TIME ###
            tabPanel("Player ranking over time",
                     h2("Ranking History"),
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
            
            
            ### WHO PLAYED WHO ###
            tabPanel("Who Played Who",
                     h2("Players' Opponent Histories at Each Tournament"),
                     sidebarPanel(
                       # select the player to focus on
                       selectizeInput(inputId = "network_player",
                                      label = "Choose a player:",
                                      choices = player_selections,
                                      multiple = FALSE
                       ),
                       
                       # select the tournament to focus on
                       selectizeInput(inputId = "network_tournament",
                                      label = "Choose a tournament:",
                                      choices = new_tournaments,
                                      multiple = FALSE,
                       ),
                     ),
                     
                     mainPanel(
                       #show network graph of opponent
                       plotlyOutput(outputId = "network", width = Inf),
                     )
                     
            )
            
)

