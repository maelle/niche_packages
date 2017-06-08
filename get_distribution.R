library("cranlogs")
all_packages <- available.packages()


get_downloads <- function(package){
  if("redland-bindings" %in% package){
    package[grep("redland", package)] <- "redland"
  }
  data <- try(cranlogs::cran_downloads(package,
                                       from = "2017-05-07",
                                       to = "2017-06-03"))
  if(methods::is(data, "try-error")){
    print(package)
    return(NULL)
  }else{
    # get no. per week
    data <- dplyr::mutate_(data, week = lazyeval::interp(quote(lubridate::week(date))))
    dots <- lapply(c("package", "week"), as.symbol)
    data <- dplyr::group_by_(data, .dots = dots)
    data <- dplyr::summarise_(data, count = lazyeval::interp(quote(sum(count))))
    
    # get median over 4 weeks
    data <- dplyr::group_by_(data, "package")
    data <- dplyr::summarise_(data, count = lazyeval::interp(quote(stats::median(count))))
    return(data)                  
  }
  
}

all_packages <- unname(all_packages[,1])
sp <- split(all_packages, ceiling(seq_along(all_packages)/100))
downloads <- purrr::map_df(sp, get_downloads)

# rOpenSci packages
ropensci <- jsonlite::fromJSON("https://raw.githubusercontent.com/ropensci/roregistry/master/registry.json")
ropensci_packages <- ropensci$packages
ropensci_packages <- dplyr::filter(ropensci_packages, on_cran, !cran_archived)


downloads <- dplyr::mutate(downloads, ropensci = (package %in% ropensci_packages$name))


readr::write_csv(downloads, path = "downloads.csv")

