### script to generate markdown page
dat <- read.table("./data/operator_list.csv", header = TRUE, sep = ",")
head(dat)

dat$description <- sapply(dat$ï..name, function(x) {
  raw <- try(readLines(paste0("https://raw.githubusercontent.com/tercen/",x,"/master/README.md")))
  if(class(raw) == "try-error") {
    return(NA)
  } else {
    desc <- try(raw[(grep("Description", raw) + 1):(grep("Usage", raw) - 1)])
    if(class(desc) == "try-error") desc <- NA
    return(paste0(desc, collapse=""))
  }
})

chapters <- c("Basic statistics",
              "Basic data transformation",
              "Basic operations",
              "File conversion",
              "Statistical testing",
              "Data visualisation",
              "Pairwise distances",
              "Dimensionality reduction and clustering",
              "Flow Cytometry",
              "RNA sequencing",
              "Template")

for(i in seq_along(chapters)) {
  chap <- chapters[i]
  d <- dat[dat$category == chap & !is.na(dat$category), ]
  
  cat(
    paste("#", chap, "\n"),
    paste("\n##", d$ï..name, " {-}\n\nDescription:", d$description, "\n\nLink:", d$url, "\n"),
    file = paste0(
      formatC(i, width = 2, format = "d", flag = "0"), "-", gsub(" ", "-", chap), ".Rmd"
    )
  )
  
}



## 

## 

## 

## 

##                     

## Template

