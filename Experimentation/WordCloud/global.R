library(readr)
# 3hrs
# load our data into the app
atp_table <- read_csv("atp_tennis.csv", show_col_types = FALSE)

#take reformatting info from lab 3 to get the full names of the players
library(magrittr)




library(tm)
library(wordcloud)
library(memoise)

# The list of valid selections
selections <<- list("Top 50 ATP Tournaments" = "tournamnets",
               "Top 50 appearences by players" = "players")

# Using "memoise" to automatically cache the results
getTermMatrix <- memoise(function(selection) {
  # Careful not to let just any name slip in here; a
  # malicious user could manipulate this value.
  if (!(selection %in% selections))
    stop("not a possible selection")
  if(selection == selections$`Top 50 appearences by players`){
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

