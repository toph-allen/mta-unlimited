library(dplyr)
library(magrittr)

load("data/metrocard.RData")
load("data/ny_census_tracts.RData")

acs13_5yr <- read.csv("rawdata/ACS_13_5YR_B08101/ACS_13_5YR_B08101.csv", skip = 1, as.is = TRUE)

acs_transit <- acs13_5yr %>%
  select(fips = Id2,
         acs_total = Estimate..Total.,
         use_transit = Estimate..Total....Public.transportation..excluding.taxicab..) %>%
  mutate(fips = as.character(fips))

rm(acs13_5yr)

# Summarize totals by borough

acs_boro <- nyc_census_tracts %>%
  select(fips, borough) %>%
  left_join(acs_transit) %>%
  group_by(borough) %>%
  summarize(boro_transit_5yr = sum(use_transit, na.rm = TRUE))

metrocard_boro <- metrocard %>%
  group_by(borough) %>%
  summarize(boro_transit_daily = sum(daily_riders, na.rm = TRUE))

boro <- full_join(metrocard_boro, acs_boro)

acs_nyc_transit <- acs_transit %>%
  inner_join(select(nyc_census_tracts, fips, borough)) %>%
  left_join(boro) %>%
  mutate(transit_daily_estimate = use_transit * (boro_transit_daily / boro_transit_5yr))

save(acs_nyc_transit, file = "data/acs_nyc_transit.RData")