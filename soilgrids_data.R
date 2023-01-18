library(XML)
library(rgdal)
library(gdalUtils)
library(raster)
library(sf)
library(dplyr)
library(RColorBrewer)
library(leaflet.opacity)
library(leaflet)
library(mapview)
library(terra)

# Read-in data with GPS coordinates
pts0 <- read.csv('~/Alliance/Job/Data/Metadata/Bolo/Literature_reviewed.csv') #  Read a file with gps coords

pts0 <- pts0 %>%
dplyr::select(c('Longitude', 'Latitude')) # Match these columns with the gps coordinates you have read above

names(pts0) <- c('lon','la')

pts0 <- as.matrix(pts0)
#set coordinate system to homosline crs as SoilGrids uses this
igh <- '+proj=igh +lat_0=0 +lon_0=0 +datum=WGS84 +units=m +no_defs'

sites <- vect(pts0, crs = igh) 
#You may include geom = (c"x", "y") in vect() if using a data.frame of coordinates

vars <- c("bdod", "cfvo", "clay", "nitrogen", "ocd", "ocs", "phh2o", "sand", "silt", "soc") # cec is missing
depth <- c(5,15,30)
var <- soil_world(var=vars[2], depth = depth[1], stat="mean", path="~/Alliance/Job/Data/Metadata/") 

#download data using soil_world; giving an example of 1 variable
rpH5 <- soil_world(var="phh2o", depth=5, stat="mean", path="~/Alliance/Job/Data/Metadata/") #I created an Rdata folder in my Rproj so I can organize the data better
rpH15 <- soil_world(var="phh2o", depth=15, stat="mean", path="~/Alliance/Job/Data/Metadata/") #I created an Rdata folder in my Rproj so I can organize the data better
rpH30 <- soil_world(var="phh2o", depth=30, stat="mean", path="~/Alliance/Job/Data/Metadata/") #I created an Rdata folder in my Rproj so I can organize the data better


#extract the SoilGrids data based on the coordinate
values_pH5 <- terra::extract(rpH5, sites)
values_pH15 <- terra::extract(rpH15, sites)
values_pH30 <- terra::extract(rpH30, sites)

values_pH5 #check if any NA values? If so, may need to add na.rm = TRUE in extract()
sites <- cbind.data.frame(crds(sites), values_pH5[,2],values_pH15[,2],values_pH30[,2]) #binding together data and the original coordinates.