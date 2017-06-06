library("ggplot2")
downloads <- readr::read_csv("downloads.csv")

dw


ggplot(downloads) +
  geom_histogram(aes(no_downloads)) +
  scale_x_log10() +
  geom_point(aes(x = no_downloads), y = 0, shape = "|",
             col = "blue", size = 1.2,
             data = dplyr::filter(downloads, ropensci))

ggsave(file = "no_downloads.png", height = 6, width = 6)
