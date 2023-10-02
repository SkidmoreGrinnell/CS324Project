

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
  
  output$rank_trends <- renderPlot({
    player_name <- input$players
    atp_player_results <- atp_table %>%
      filter(Player_1 == player_name |
               Player_2 == player_name) %>%
      select(Rank_1 | Rank_2 | Date | Player_1 | Player_2) %>%
      mutate(player_ranking = 
               ifelse(Player_1 == player_name, Rank_1, Rank_2))
    
    atp_player_results$Date <- as.Date(atp_player_results$Date)
    
    atp_player_results %>%
      ggplot( aes(x=Date, y=player_ranking)) +
      geom_line() +
      geom_point() +
      scale_y_reverse()
  })
}

