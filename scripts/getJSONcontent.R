# script to get operator json files

library(gh)
library(base64enc)
library(jsonlite)

load(file = "./data/last-op_jsons.rda")
load(file = "./data/last-op_tags.rda")
# load op_jsons df

cnames <- unique(unlist(lapply(op_jsons, names)))
cnames <- cnames[!cnames %in% c("properties")]

mat <- matrix(NA, nrow = length(op_jsons), ncol = length(cnames))
df <- as.data.frame(mat)
colnames(df) <- cnames
# i <- 18
for(i in 1:nrow(df)) {
  lst <- op_jsons[[i]]
  if(!is.na(lst)) {
    lst$tags <- paste0(lst$tags, collapse = "; ")
    vec <- unlist(lst)
    idx <- grep("properties", names(vec))
    if(length(idx) > 0) vec <- vec[-idx]
    idx <- grep("authors", names(vec))
    if(length(idx) > 0) vec <- vec[-idx]
    df[i, names(vec)] <- unname(vec)
  }
}
df$latest_tag <- unlist(op_tags)

df$description <- gsub(",", ";", df$description)

tstamp <- format(Sys.time(), "%Y%m%d-%H%M")
out.name <-  paste0("./data/", tstamp, "-operator-jsons.csv")

write.table(df, file = out.name, sep = ",", quote=FALSE, row.names = FALSE)
