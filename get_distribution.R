library("cranlogs")
set.seed(1)
all_packages <- available.packages()
some_packages <- sample(all_packages[,1], size = 1000)


get_downloads <- function(package){
  data <- cranlogs::cran_downloads(package,
                           when = "last-week")
  data.frame(package = package,
             no_downloads = sum(data$count))
}

downloads <- purrr::map_df(some_packages, get_downloads)
readr::write_csv(downloads, path = "downloads.csv")