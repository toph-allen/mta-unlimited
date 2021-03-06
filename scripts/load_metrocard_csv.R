library(dplyr)
library(magrittr)

metrocard <- read.csv("rawdata/metrocard-usage.csv", as.is = TRUE)

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

# The one NA for Borough is actually in Queens--it's Mets - Willets Point on the 7.
metrocard$borough[is.na(metrocard$borough)] <- "Queens"

save(metrocard, file = "data/metrocard.RData")
