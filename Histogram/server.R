function(input, output) {
output$main_plot <- renderPlot({
  
  hist(atp_table$Rank_1,
       probability = TRUE,
       breaks = as.numeric(input$n_breaks),
       xlab = "Rank of player 1",
       main = "instances")
  
  if (input$individual_obs) {
    rug(faithful$eruptions)
  }
  
  if (input$density) {
    dens <- density(faithful$eruptions,
                    adjust = input$bw_adjust)
    lines(dens, col = "blue")
  }
  
})
}