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


