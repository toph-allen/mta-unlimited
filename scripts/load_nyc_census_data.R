library(dplyr)
library(magrittr)

# Load US census data

library(UScensus2010)
library(UScensus2010tract)

data(new_york.tract10)

ny_tracts <- as.tbl(new_york.tract10@data)

# Load NYC 2010 census tabulation equivalent

nyc_census_equiv <- read.csv("rawdata/nyc2010census_tabulation_equiv.csv",
                             as.is = TRUE,
                             colClasses = rep("character", 7),
                             col.names = c("borough",
                                           "fips_county",
                                           "boro",
                                           "census_tract",
                                           "puma",
                                           "nta_code",
                                           "nta_name"))

nyc_census_equiv %<>%
  mutate(boro_census_tract = paste0(boro, census_tract))

nyc_census_tracts <- left_join(nyc_census_equiv, ny_tracts,
                        by = c("fips_county" = "county",
                               "census_tract" = "tract"))

save(nyc_census_tracts, file = "data/ny_census_tracts.RData")
