

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
  
  output$wordcloud <- renderPlot({
    v <- terms()
    par(mar = c(0, 0, 0, 0))
    wordcloud_rep(words = v$name,
                  freq = v$freq,
                  scale=c(input$size/7,0.01),
                  max.words=input$max,
                  colors=brewer.pal(8, "Dark2"))
  })
  
  #make the histogram
  output$histogram <- renderPlot({
    
    hist(atp_table$Rank_1,
         probability = TRUE,
         breaks = as.numeric(input$n_breaks),
         xlab = "Rank of player",
         main = "Percent occurance vs Rank")
    
    if (input$individual_obs) {
      rug(atp_table$Rank_1)
    }
    
    if (input$density) {
      dens <- density(atp_table$Rank_1,
                      adjust = input$bw_adjust)
      lines(dens, col = "blue")
    }
    
  })
  
  output$rank_trends <- renderPlotly({
    req(input$players)
    player_results <- list()
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
    # https://www.geeksforgeeks.org/plot-lines-from-a-list-of-dataframes-using-ggplot2-in-r/
    p <- ggplot(bind_rows(player_results, .id="data_frame"),
                aes(x=Date, y=Rank_1)) +
      geom_line(aes(color = Player)) +
      scale_y_reverse() +
      labs(y = "Ranking", title = "Player Ranking over Time")
    ggplotly(p)
  })
  output$network <- renderPlotly({
    req(input$network_player)
    
    player = input$network_player
    atp_player_result <- atp_combined %>%
      filter(Player_1 == player) %>%
      # grab names ranks and dates
      select(Player_2)
    #make a data frame with the frequency of occurrences
    network_table_df <- atp_player_result %>%
      table(dnn = list("name")) %>%
      as.data.frame(responseName = "freq")
    #order by frequency
    network_table_df <- network_table_df[order(network_table_df$freq, decreasing = TRUE),]
    simple_edge_df <- data.frame(
      from = rep(player,length(network_table_df$name)),
      to = network_table_df$name,
      weight = network_table_df$freq
    )
    
    net <- graph_from_data_frame(simple_edge_df)
    p <- ggnet2(simplify(net), size = 3, label = TRUE)
    ggplotly(p)
  })
  
}

