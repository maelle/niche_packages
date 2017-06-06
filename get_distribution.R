library("cranlogs")
set.seed(1)
all_packages <- available.packages()
some_packages <- sample(all_packages[,1], size = 1000)


get_downloads <- function(package){
  if(package == "redland-bindings"){
    package <- "redland"
  }
  data <- try(cranlogs::cran_downloads(package,
                           when = "last-month"))
  if(methods::is(data, "try-error")){
    print(package)
    return(NULL)
  }else{
    data <- dplyr::mutate_(data, week = lazyeval::interp(quote(lubridate::week(date))))
    data <- dplyr::group_by_(data, "week")
    data <- dplyr::filter_(data, lazyeval::interp(quote(n() == 7)))
    data <- dplyr::summarise_(data, count = lazyeval::interp(quote(sum(count))))
    count <- median(data$count)
    return(data.frame(package = package,
                      no_downloads = count))
  }
  
}

downloads <- purrr::map_df(some_packages, get_downloads)

# rOpenSci packages
ropensci <- jsonlite::fromJSON("https://raw.githubusercontent.com/ropensci/roregistry/master/registry.json")
ropensci_packages <- ropensci$packages
ropensci_packages <- dplyr::filter(ropensci_packages, on_cran)
ropensci_downloads <- purrr::map_df(ropensci_packages$name, get_downloads)
ropensci_downloads <- dplyr::mutate(ropensci_downloads, ropensci = TRUE)

downloads <- dplyr::filter(downloads, !package %in% ropensci_packages$name)
downloads <- dplyr::mutate(downloads, ropensci = FALSE)
downloads <- dplyr::bind_rows(downloads, ropensci_downloads)

readr::write_csv(downloads, path = "downloads.csv")

