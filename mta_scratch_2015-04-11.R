library(dplyr)
library(magrittr)
library(ggplot2)
library(ggmap)

metrocard <- read.csv("metrocard-usage.csv", as.is = TRUE)
metrocard <- as.tbl(metrocard)

metrocard

# Test doing a map of NYC with points from the metrocard dataset
nycmap <- get_googlemap("new york", scale = 4, zoom = 11, maptype = "roadmap")
ggmap(nycmap) + geom_point(aes(x = longitude, y = latitude, size = daily_riders, color = pct_7day), data = metrocard)
ggmap(nycmap) + geom_point(aes(x = longitude, y = latitude, size = daily_riders, fill = pct_7day), color = "black", pch = 21, data = metrocard)

ggsave("~/Desktop/test_googlemap.png")
ggmap(get_map("new york", source = "stamen", maptype = "toner")) + geom_point(aes(x = longitude, y = latitude, size = daily_riders, fill = pct_7day), color = "black", pch = 21, data = metrocard)
ggmap(get_map("new york", source = "stamen", maptype = "toner-lite")) + geom_point(aes(x = longitude, y = latitude, size = daily_riders, fill = pct_7day), color = "black", pch = 21, data = metrocard)

first_elements = function(x) {
  y <- strsplit(x, ",")
  sapply(y, "[", 1)
}

metrocard_by_borough <- metrocard %>%
  mutate(borough = first_elements(pretty_census_tract),
         pct_other = 1 - (pct_30day + pct_7day),
         daily_30day = daily_riders * pct_30day,
         daily_7day = daily_riders * pct_7day,
         daily_other = daily_riders * pct_other) %>%
  group_by(borough) %>%
  summarize(daily_30day = sum(daily_30day),
            daily_7day = sum(daily_7day),
            daily_other = sum(daily_other),
            total = sum(daily_30day, daily_7day, daily_other),
            pct_30day = daily_30day / total,
            pct_7day = daily_7day / total,
            pct_other = daily_other / total)

write.csv(metrocard_by_borough, "metrocards aggregated by borough.csv")





x <- rnorm(100)

x %<>% abs %>% sort
