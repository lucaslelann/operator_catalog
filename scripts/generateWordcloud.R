library("wordcloud")
library("tm")

help("wordcloud")

load(file = "./data/op_data.rda")

#map chapters
tag_list <- read.csv("tag_list.csv")
df$tags[df$tags == ""] <- NA
chap <- unlist(lapply(gsub(";", "|", df$tags), function(x) {
  paste0(unique(tag_list$category[grep(x, tag_list$tag)]), collapse = ", ")
}))


index <- data.frame(
  `Operator name` = df$name,
  Chapter = chap,
  `Tags` = gsub(";", ", ", df$tags)
)

concatenated <- paste(unlist(index), collapse = " ")
concatenated <- gsub("_", " ", concatenated)
png("./data/wordcloud.png")
wc <- wordcloud(concatenated, min.freq = 1,
                max.words=200, random.order=FALSE, rot.per=0.35, 
                colors=brewer.pal(8, "Dark2"))
dev.off()
