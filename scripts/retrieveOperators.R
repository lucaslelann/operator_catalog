library(rvest)
npages <- 1:5
op.list <- NULL
for (n in npages) {
  
  URL <- paste0("https://github.com/tercen?language=&page=", n, "&q=operator&type=")
  scrap <- xml2::read_html(URL)
  links <- scrap %>%
    html_nodes("[itemprop='name codeRepository']") %>%
    html_attr("href") 
  
  op.list <- c(op.list, links)
  Sys.sleep(1)
}

# get tags


op.list

library("rjson")
json_file <- "http://api.worldbank.org/country?per_page=10&region=OED&lendingtype=LNX&format=json"
json_data <- fromJSON(paste(readLines(json_file), collapse=""))


tags <- sapply(op.list, function(x) {
  
  raw <- try(fromJSON(
    paste(readLines(
      paste0("https://raw.githubusercontent.com",x,"/master/operator.json")
      ), collapse = "")
  ))
  
  if(class(raw) == "try-error") {
    return(NA)
  } else {
    tags <- try(raw$tags)
    if(class(tags) == "try-error") tags <- NA
    return(paste0(tags, collapse="; "))
  }
  
})

df <- data.frame(name = names(tags), tags = tags)
write.csv(df, file = "./data/all-tags.csv", quote = FALSE, row.names = FALSE)
