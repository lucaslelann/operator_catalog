library(gh)

tk <- readLines("./scripts/ghtoken")
n_pages <- 7
repos <- do.call(rbind, lapply(seq_len(n_pages), function(x) {
  repo_list <- gh("GET /users/tercen/repos", page = x, .token = tk)
  repo_names <- vapply(repo_list, "[[", "", "name")
  repo_url <- vapply(repo_list, "[[", "", "html_url")
  repo_issues <- vapply(repo_list, "[[", 1, "open_issues")
  return(data.frame(repo_names, repo_url, repo_issues))
}))

tstamp <- format(Sys.time(), "%Y%m%d-%H%M")
out.name <-  paste0("./data/", tstamp, "-repos.csv")
write.csv(df, file = out.name, quote = FALSE, row.names = FALSE)

library("base64enc")

repo_list <- repos$repo_names[grep("_operator", repos$repo_names)]
op_readmes <- lapply(repo_list, function(x) {
  ct <- gh(paste0("GET /repos/tercen/", x, "/readme"), .token = tk)
  decoded <- rawToChar(base64decode(ct$content))
  return(decoded)
})


names(op_readmes) <- repo_list
save(op_readmes, file = "./data/op_readmes.rda")

library(jsonlite)
op_jsons <- lapply(repo_list, function(x) {
  ct <- try(gh(paste0("GET /repos/tercen/", x, "/contents/operator.json"), .token = tk))
  if(class(ct) == "try-error") {
    out <- NA
  } else {
    decoded <- rawToChar(base64decode(ct$content))
    out <- fromJSON(decoded) 
  }
  return(out)
})
names(op_jsons) <- repo_list
save(op_jsons, file = "./data/op_jsonss.rda")
