library(readr)

# load our data into the app
atp_table <- read_csv("atp_tennis.csv", show_col_types = FALSE)

#take reformatting info from lab 3 to get the full names of the players
library(magrittr)




library(tm)
library(wordcloud)
library(memoise)

# The list of valid selections
selections <<- list("Top ATP Tournaments by match count" = "tournamnets",
               "Top players by total amount of appearances" = "players")

# make a list of the top 50 players by frequency to allow for ranking viewing
player_selections <<- data.frame( player = 
                                    c(atp_table$Player_1, 
                                      atp_table$Player_2)) %>%
  table(dnn = list("name")) %>%
  as.data.frame(responseName = "freq") %>%
  .[order(.$freq, decreasing = TRUE),] %>%
  head(50)

# Using "memoise" to automatically cache the results
getTermMatrix <- memoise(function(selection) {
  # Careful not to let just any name slip in here; a
  # malicious user could manipulate this value.
  if (!(selection %in% selections))
    stop("not a possible selection")
  if(selection == selections$`Top players by total amount of appearances`){
    # grab all instances of names, count frequency, make data frame
    atp_names <- data.frame( player = c(atp_table$Player_1, atp_table$Player_2))
    result <- atp_names #result
  }
  else{
    result <- atp_table$Tournament #result
  }
  result %<>% table(dnn = list("name"))
  result %<>% as.data.frame(responseName = "freq")
  result <- result[order(result$freq, decreasing = TRUE),]
  
})

