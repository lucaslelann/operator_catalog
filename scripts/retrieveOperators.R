library(gh)
library(base64enc)
library(jsonlite)

tstamp <- format(Sys.time(), "%Y%m%d-%H%M")

tk <- readLines("./scripts/ghtoken")
n_pages <- 7

######
## 1. get repository list and basic info
repos <- do.call(rbind, lapply(seq_len(n_pages), function(x) {
  repo_list <- gh("GET /users/tercen/repos", page = x, .token = tk)
  repo_names <- vapply(repo_list, "[[", "", "name")
  repo_url <- vapply(repo_list, "[[", "", "html_url")
  repo_issues <- vapply(repo_list, "[[", 1, "open_issues")
  return(data.frame(repo_names, repo_url, repo_issues))
}))

out.name <-  paste0("./data/", tstamp, "-repos.csv")
write.csv(repos, file = "./data/last-repos.csv", quote = FALSE, row.names = FALSE)
write.csv(repos, file = out.name, quote = FALSE, row.names = FALSE)


repo_list <- repos$repo_names[grep("_operator", repos$repo_names)]

######
## 2. check contents of repositories
op_content_checking <- lapply(repo_list, function(x) {
  ct <- try(gh(paste0("GET /repos/tercen/", x, "/contents"), .token = tk))
  
  if(class(ct) == "try-error") {
    out <- NA
  } else {
    
    fnames <- vapply(ct, "[[", "", "name")
    
    is_renv_initiated <- length(grep("renv", fnames)) > 0
    is_packrat_initiated <- length(grep("packrat", fnames)) > 0
    
    has_JSON <- length(grep("operator.json", fnames)) > 0
    has_README <- length(grep("README.md", fnames)) > 0
    has_mainR <- length(grep("main.R", fnames)) > 0
    
    ctest <- try(gh(paste0("GET /repos/tercen/", x, "/contents/test"), .token = tk))
    if(class(ctest) == "try-error") {
      has_test_dir <- FALSE
      has_test_content <- FALSE
      has_test_json <- FALSE
      has_test_2_csv <- FALSE
    } else {
      has_test_dir <- TRUE
      tnames <- vapply(ctest, "[[", "", "name")
      has_test_content <- length(tnames) >= 3 
      has_test_json <- length(grep("json", tnames)) > 0
      has_test_2_csv <- length(grep("csv", tnames)) >= 2
    }
  }
  
  out <- data.frame(
    is_renv_initiated, is_packrat_initiated, has_JSON, has_README,
    has_mainR, has_test_dir, has_test_content, has_test_json, has_test_2_csv
  )
  return(out)
})
names(op_content_checking) <- repo_list 
op_check_out <- do.call(rbind, op_content_checking)
op_check_out$missing <- rowSums(!op_check_out)
op_check_out$name <- rownames(op_check_out)

out.name <-  paste0("./data/", tstamp, "-operator_check.csv")
write.csv(op_check_out, file = out.name, quote = FALSE, row.names = FALSE)
write.csv(op_check_out, file = "./data/last-operator_check.csv", quote = FALSE, row.names = FALSE)

######
## 3. get READMEs of repositories
op_readmes <- lapply(repo_list, function(x) {
  ct <- gh(paste0("GET /repos/tercen/", x, "/readme"), .token = tk)
  decoded <- rawToChar(base64decode(ct$content))
  return(decoded)
})

names(op_readmes) <- repo_list
save(op_readmes, file = "./data/last-op_readmes.rda")
save(op_readmes, file = paste0("./data/",tstamp,"-op_readmes.rda"))

######
## 4. get JSON files of repositories
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
save(op_jsons, file = "./data/last-op_jsons.rda")
save(op_jsons, file = paste0("./data/",tstamp,"-op_jsons.rda"))

######
## 5. merge readmes and jsons for catalog generation
df <- data.frame(
  name = names(op_readmes),
  README = unlist(op_readmes),
  tags = unlist(lapply(op_jsons[names(op_readmes)], function(x) paste0(x["tags"][[1]], collapse = ";")))
)
save(df, file = "./data/last-op_data.rda")
save(df, file = paste0("./data/",tstamp,"-op_data.rda"))
