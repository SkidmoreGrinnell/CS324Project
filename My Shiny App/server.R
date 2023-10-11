

function(input, output, session) {
  # Define a reactive expression for the document term matrix
  terms <- reactive({
    # Change when the "update" button is pressed...
    input$update
    # ...but not for anything else
    isolate({
      withProgress({
        setProgress(message = "Processing data...")
        getTermMatrix(input$selection)
      })
    })
  })
  
  # Make the wordcloud drawing predictable during a session
  wordcloud_rep <- repeatable(wordcloud)
  
  
  ### WORD CLOUD ###
  # this renders the word cloud plot
  output$wordcloud <- renderPlot({
    # grab the terms from the terms() in global
    v <- terms()
    # remove graph padding so it does not clip when size increases
    par(mar = c(0, 0, 0, 0))
    # make the word cloud with user chosen size and max words
    wordcloud_rep(words = v$name,
                  freq = v$freq,
                  scale=c(input$size/7,0.01),
                  max.words=input$max,
                  colors=brewer.pal(8, "Dark2"))
  })
  
  ### HISTOGRAM ###
  #make the histogram
  output$histogram <- renderPlot({
    
    # make a graph with a variable number of bins using
    #     breaks = as.numeric(input$n_breaks)
    # use a density curve so we can add a density line to the graph
    #     probability = TRUE,
    #         AND
    #     dens <- density(atp_table$Rank_1, adjust = input$bw_adjust)
    hist(atp_table$Rank_1,
         probability = TRUE,
         breaks = as.numeric(input$n_breaks),
         xlab = "Rank of player",
         xlim = c(0,as.numeric(input$max_ranking)),
         main = "What are rankings at ATP tournaments",
         col = "lightgreen")
    
    # show how individuals appear on the graph according to rank
    if (input$individual_obs) {
      rug(atp_table$Rank_1)
    }
    
    # a density curve placed onto the graph
    if (input$density) {
      dens <- density(atp_table$Rank_1,
                      adjust = input$bw_adjust)
      lines(dens, col = "blue")
    }
    
  })
  
  ### PLAYER RANKING OVER TIME ###
  # a line graph showing rankings
  output$rank_trends <- renderPlotly({
    # wait for selection
    req(input$players)
    
    # make an empty list of results
    player_results <- list()
    
    # fill the list according to the selections
    for(player in input$players){
      # grab the relevant player ratings
      atp_player_result <- atp_combined %>%
        filter(Player_1 == player) %>%
        # grab names ranks and dates
        select(Rank_1 | Rank_2 | Date | Player_1 | Player_2)%>%
        rename(Player = Player_1)
      # add the player result to the list
      player_results[[length(player_results)+1]] = atp_player_result
    }
    # help from:
    #   https://www.geeksforgeeks.org/plot-lines-from-a-list-of-dataframes-using-ggplot2-in-r/
    # make a data frame from the rows
    # make lines corresponding to a different color depending on the player
    # make the scale reversed as rank 1 should be higher
    # lastly change the axis
    p <- ggplot(bind_rows(player_results, .id="data_frame"),
                aes(x=Date, y=Rank_1)) +
      geom_line(aes(color = Player)) +
      scale_y_reverse() +
      labs(y = "Ranking", title = "Player Ranking over Time")
    ggplotly(p)
  })
  
  ### WHO PLAYED WHO ###
  # make a player network to show
  output$network <- renderPlotly({
    req(input$network_player, input$network_tournament)
    
    # take the player input and tournament
    # filter the combined data by the player's name and tournament
    # grab all of the opponents' names
    player = input$network_player
    tournament = input$network_tournament
    atp_player_result <- atp_combined %>%
      filter(Player_1 == player & Tournament == tournament) %>%
      select(Player_2)
    # turn the opponents into a frequency table
    #   make sure the players have the column name "name"
    #   make sure the frequency column has the name "freq"
    #   order by frequency
    network_table_df <- atp_player_result %>%
      table(dnn = list("name")) %>%
      as.data.frame(responseName = "freq")
    network_table_df <- network_table_df[order(network_table_df$freq, decreasing = TRUE),]
    
    # make a data frame with player -> opponent
    # include the weights (which is the amount of times they have played)
    edge_df <- data.frame(
      from = rep(player,length(network_table_df$name)),
      to = network_table_df$name,
      weight = network_table_df$freq
    )
    
    # make a network graph from the data frame 
    #     create a plot from simple network (only one connection)
    #     add labels to see player names
    #     adjust the x and y axis to always fit the names on the plots
    #     turn off hover insights because info is not helpful
    #   helpful insight from:
    #       https://rdrr.io/github/briatte/ggnet/f/vignettes/ggnet2.Rmd
    net <- graph_from_data_frame(edge_df)
    p <- ggnet2(simplify(net), size = 1, label = TRUE, node.color = "lightgreen",
                edge.color = "blue", edge.size = .1)
    fig <- ggplotly(p) %>% layout(xaxis = list(visible = FALSE,
                                               range = list(-.15, 1.15)),
                                yaxis = list(visible = FALSE,
                                             range = list(-.1, 1.1)),
                                hovermode = FALSE)
  })
  
  # Change selection inputs on WHO PLAYED WHO #
  # reactive tournament selection for the network
  #     not every player has played every tournament
  observe({
    #     take player selection
    #     filter results
    #     grab tournament names
    player_for_update <- input$network_player
    atp_player_result_all <- atp_combined %>%
      filter(Player_1 == player_for_update)  
    new_tournaments_updated <- atp_player_result_all[!duplicated(atp_player_result_all$Tournament), "Tournament"]
    
    # input the player selection into network_tournament selection ui element
    updateSelectizeInput(session, "network_tournament", choices = new_tournaments_updated)
  })
  
  
  
  
}

