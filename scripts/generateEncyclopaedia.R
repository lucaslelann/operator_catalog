### script to generate markdown page

df <- data.frame(
  name = names(op_readmes),
  README = unlist(op_readmes),
  tags = unlist(lapply(op_jsons[names(op_readmes)], function(x) paste0(x["tags"][[1]], collapse = ";")))
)

tag_map <- read.table("./tag_list.csv", sep=",", header = TRUE)
tag_map


for(i in seq_along(tag_map$category)) {
  
  chap <- tag_map$category[i]
  cat_tag <- tag_map[tag_map$category == chap, ]$tag
  cat_id <- grep(cat_tag, df$tags)
  # df[cat_id, ]$README
  
  cat(
    paste("#", chap, "\n"),
    paste0("\n\n#", df[cat_id, ]$README), # ADD URL
    file = paste0(
      formatC(i, width = 2, format = "d", flag = "0"), "-", gsub(" ", "-", chap), ".Rmd"
    )
  )
  
}


bookdown::render_book(input = "index.Rmd", output_dir = "docs")
