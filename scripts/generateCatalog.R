### script to generate markdown page
load(file = "./data/op_readmes.rda")
load(file = "./data/op_jsonss.rda")

df <- data.frame(
  name = names(op_readmes),
  README = unlist(op_readmes),
  tags = unlist(lapply(op_jsons[names(op_readmes)], function(x) paste0(x["tags"][[1]], collapse = ";")))
)

tag_map <- read.table("./tag_list.csv", sep=",", header = TRUE)
std_cat <- tag_map$category[tag_map$type == "standard"]
for(i in seq_along(std_cat)) { #i <- seq_along(tag_map$category[tag_map$type == "standard"])[1]
  
  chap <- std_cat[i]
  cat_tag <- tag_map[tag_map$category == chap, ]$tag
  cat_id <- grep(paste0(cat_tag, collapse="|"), df$tags)

  # reformat readme
  rdm <- gsub("(-{2,})", ":\\1", df[cat_id, ]$README)
  rdm <- gsub("#{3,}", "#####", rdm)
  rdm <- paste0("\n\n#", rdm)
  rdm <- paste0(rdm, "\n\n##### GitHub link\n\n[",df[cat_id, ]$name," on GitHub](https://github.com/tercen/",df[cat_id, ]$name,")")

  cat(
    paste("#", chap, "\n"),
    rdm,
    file = paste0(
      formatC(i, width = 2, format = "d", flag = "0"), "-", gsub(" ", "-", chap), ".Rmd"
    )
  )
  
}

bookdown::render_book(input = "index.Rmd", output_dir = "docs")

