library(dplyr)
library(magrittr)
library(ggplot2)
library(leaflet)
library(sp)

metrocard <- read.csv("rawdata/metrocard-usage.csv", as.is = TRUE)
metrocard <- as.tbl(metrocard)

first_elements = function(x) {
  y <- strsplit(x, ",")
  sapply(y, "[", 1)
}

metrocard %<>%
  mutate(borough = first_elements(pretty_census_tract),
         pct_other = 1 - (pct_30day + pct_7day),
         daily_30day = daily_riders * pct_30day,
         daily_7day = daily_riders * pct_7day,
         daily_other = daily_riders * pct_other)

save(metrocard, file = "data/metrocard.RData")