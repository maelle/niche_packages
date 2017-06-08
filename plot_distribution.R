library("ggplot2")
library("dplyr")
library("hrbrthemes")
downloads <- readr::read_csv("downloads.csv")


ggplot(downloads) +
  geom_histogram(aes(count)) +
  scale_x_log10() +
  geom_point(aes(x = count), y = 0, shape = "|",
             col = "blue", size = 1.2,
             data = dplyr::filter(downloads, ropensci)) +
  xlab("total number of downloads over the last 4 weeks") +
  theme_ipsum()

ggsave(file = "no_downloads.png", height = 6, width = 6)


# another attempt 
# FIXME: the bar reordering is being lost though when adding the rug, 
# not sure how to fix it
min_ropensci <- downloads %>% filter(ropensci) %>% arrange(count) %>% .$count %>% min
down <- downloads %>% filter(count > min_ropensci)

ggplot(down) +
  geom_bar(aes(reorder(package, count), count), stat = "identity") + 
  geom_rug(aes(reorder(package, count), y = 0), color = "blue",
           data = dplyr::filter(downloads, ropensci)) +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())