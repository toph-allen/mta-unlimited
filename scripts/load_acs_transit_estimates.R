library(dplyr)
library(magrittr)

load("data/metrocard.RData")
load("data/ny_census_tracts.RData")

acs13_5yr <- read.csv("rawdata/ACS_13_5YR_B08101/ACS_13_5YR_B08101.csv", skip = 1, as.is = TRUE)

acs_transit <- acs13_5yr %>%
  select(fips = Id2,
         acs_total = Estimate..Total.,
         acs_use_transit = Estimate..Total....Public.transportation..excluding.taxicab..) %>%
  mutate(fips = as.character(fips),
         use_transit_pct = acs_use_transit / acs_total)

rm(acs13_5yr)

# Summarize totals by borough

acs_transit %<>%
  inner_join(select(nyc_census_tracts, fips, census_pop = P0010001)) %>%
  mutate(use_transit_est = use_transit_pct * census_pop)

save(acs_transit, file = "data/acs_transit.RData")
