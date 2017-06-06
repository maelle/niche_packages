library("cranlogs")
set.seed(1)
all_packages <- available.packages()
some_packages <- sample(all_packages[,1], size = 1000)


get_downloads <- function(package){
  data <- try(cranlogs::cran_downloads(package,
                           when = "last-week"))
  if(methods::is(data, "try-error")){
    print(package)
    return(NULL)
  }else{
    return(data.frame(package = package,
                      no_downloads = sum(data$count)))
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

