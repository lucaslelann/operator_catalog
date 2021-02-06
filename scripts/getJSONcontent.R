# script to get operator json files

library(gh)
library(base64enc)
library(jsonlite)

load(file = "./data/last-op_jsons.rda")
load(file = "./data/last-op_tags.rda")
# load op_jsons df

cnames <- unique(unlist(lapply(op_jsons, names)))
# columns to exclude
cnames <- cnames[!cnames %in% c("properties", "authors")]

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

df$name_from_url <- basename(df$urls)

tstamp <- format(Sys.time(), "%Y%m%d-%H%M")
out.name <-  paste0("./data/", tstamp, "-operator-jsons.csv")
out.name.xl <-  paste0("./data/", tstamp, "-operator-jsons.xlsx")

write.table(df, file = out.name, sep = ",", quote=FALSE, row.names = FALSE)
library(xlsx)
write.xlsx(df, file=out.name.xl,
           sheetName = "Operato_info",
           col.names = TRUE,
           row.names = FALSE,
           append = FALSE,
           showNA = TRUE)
