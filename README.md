# Tercen operators encyclopaedia

### Description

A catalog of all Tercen opeartors can be found here:

https://tercen.github.io/operator_encyclopaedia/

This catalog is automatically generated.

### Generate the catalog

The following script updates the operator list in `data/all-tags.csv`.

```r
source("./scripts/retrieveOperators.R")
```

The next script gets relevant information from operators repositories and generates the book.

```r
source("./generateEncyclopaedia.R")
bookdown::render_book(input = "index.Rmd", output_dir = "docs")
```