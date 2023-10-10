library(readr)

# load our data into the app
atp_table <- read_csv("atp_tennis.csv", show_col_types = FALSE)

#load in all necessary libraries for the app
library(magrittr)
library(tm)
library(wordcloud)
library(memoise)
library(dplyr)
library(ggplot2)
library(plotly)
library(GGally)
library(igraph)

# The list of valid selections for the word cloud
selections <<- list("Top ATP Tournaments by match count" = "tournamnets",
               "Top players by total amount of appearances" = "players")

# make a list of the top players ordered by frequency to allow for ranking viewing

# first make a table with all players in both the Player_1 and Player_2 lists
# this makes it easier to grab info just from the Player_1 column
atp_table_swapped <- atp_table %>% rename(Player_1 = Player_2, 
                                          Player_2 = Player_1,
                                          Rank_1 = Rank_2,
                                          Rank_2 = Rank_1,
                                          Pts_1 = Pts_2,
                                          Pts_2 = Pts_1,
                                          Odd_1 = Odd_2,
                                          Odd_2 = Odd_1)
atp_combined <- rbind(atp_table, atp_table_swapped)
atp_combined <- atp_combined[order(atp_combined$Date),]

# make a list with each tournament name
new_tournaments <- atp_table[!duplicated(atp_table$Tournament), "Tournament"]

player_selections <<- atp_combined$Player_1 %>%
  # used https://www.rdocumentation.org/packages/base/versions/3.6.2/topics/table
  # need the column name to be the same every time
  table(dnn = list("name")) %>%
  as.data.frame(responseName = "freq") %>%
  .[order(.$freq, decreasing = TRUE),]






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

