library(dplyr)
library(magrittr)

lapply(paste0("data/", list.files("data")), load, .GlobalEnv)

senate <- read.csv("rawdata/ny_senate_by_tract.csv",
                   colClasses = rep("character", 4),
                   col.names = c("fips_state", "census_tract", "fips_county", "senate_district"))

nyc_senate <- semi_join(senate, nyc_census_tracts, by = c("fips_county", "census_tract"))

assembly <- read.csv("rawdata/ny_assembly_by_tract.csv",
                   colClasses = rep("character", 4),
                   col.names = c("fips_state", "census_tract", "fips_county", "senate_district"))

nyc_assembly <- semi_join(assembly, nyc_census_tracts, by = c("fips_county", "census_tract"))

save(nyc_senate, nyc_assembly, file = "data/nyc_legislature.RData")
