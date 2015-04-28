library(dplyr)
library(magrittr)
library(ggplot2)

lapply(paste0("data/", list.files("data")), load, .GlobalEnv)


# acs_nyc_transit <- acs_transit %>%
#   inner_join(select(nyc_census_tracts, fips, borough)) %>%
#   left_join(boro) %>%
#   mutate(transit_daily_estimate = use_transit * (boro_transit_daily / boro_transit_5yr))

acs_nyc_transit2 <- acs_nyc_transit %>%
  inner_join(select(nyc_census_tracts, fips, pop_total = P0010001)) %>%
  mutate(acs_transit_pct = use_transit / acs_total,
         acs_transit_num = acs_transit_pct * pop_total)

#-------#

acs_boro <- acs_nyc_transit2 %>%
  group_by(borough) %>%
  summarize(acs_transit_pop_total = sum(acs_transit_num, na.rm = TRUE))

metrocard_boro <- metrocard %>%
  group_by(borough) %>%
  summarize(boro_transit_daily = sum(daily_riders, na.rm = TRUE))

#-------#

boro <- full_join(metrocard_boro, acs_boro)

acs_nyc_transit3 <- acs_nyc_transit2 %>%
  left_join(boro) %>%
  mutate(transit_daily_estimate2 = acs_transit_num * (boro_transit_daily / acs_transit_pop_total),
         pct_transit_daily_est2 = transit_daily_estimate2 / pop_total,
         pct_transit_daily_est = transit_daily_estimate / pop_total)

# We have a problem, in that for some census tracts, the simple estimating we're
# doing leads to us saying that we think more people ride the subway from a
# particular census tract than *live* in that census tract.

#-------#

library(UScensus2010tract)
library(sp)

data(new_york.tract10)

names(new_york.tract10@data)

nyc_sp <- new_york.tract10[new_york.tract10$fips %in% acs_nyc_transit3$fips, ]

nyc_sp <- merge(nyc_sp, acs_nyc_transit3)

plot(nyc_sp)



nyc_sp@data$id <- rownames(nyc_sp@data)
nyc_points <- fortify(nyc_sp, region = "id")
ggnyc <- left_join(nyc_points, nyc_sp@data)


qplot(long, lat, data = ggnyc, geom = "polygon", group = group, fill = pct_transit_daily_est)
qplot(long, lat, data = ggnyc, geom = "polygon", group = group, fill = pct_transit_daily_est2)


library(leaflet)
leaflet(data = nyc_sp)
