####Inastall packages####

#install.packages("maptools")
#install.packages("rgdal")
#install.packages("raster")
#install.packages("rgeos")
#install.packages("rasterVis")
#install.packages("RCurl")
#install.packages("devtools")
#install.packages("ggmap")
#install.packages("tidyverse")

####Attaching packages into library####

library(maptools)
library(rgdal)
library(raster)
library(rgeos)
library(rasterVis)
library(RCurl)
library(devtools)
library(ggmap)
library(tidyverse)

####Set working directory####

setwd("C:/Users/Martin/Desktop/R_Course")

#### Load Sentinel 2 data into R####

###Prefire Image from the 6th of November 2018 at 18:55:56 PM during relative Orbit 113###

##Prefire 2 Tiles Band8##

PrefireB81 <- raster("Data/Sentinel2/Prefire/S2B_MSIL1C_20181106T185559_N0207_R113_T10SFJ_20181106T204800/S2B_MSIL1C_20181106T185559_N0207_R113_T10SFJ_20181106T204800.SAFE/GRANULE/L1C_T10SFJ_A008719_20181106T190027/IMG_DATA/T10SFJ_20181106T185559_B08.jp2")
PrefireB82 <- raster("Data/Sentinel2/Prefire/S2B_MSIL1C_20181106T185559_N0207_R113_T10TFK_20181106T204800/S2B_MSIL1C_20181106T185559_N0207_R113_T10TFK_20181106T204800.SAFE/GRANULE/L1C_T10TFK_A008719_20181106T190027/IMG_DATA/T10TFK_20181106T185559_B08.jp2")

##prefire 2 Tiles Band12##

PrefireB121 <- raster("Data/Sentinel2/Prefire/S2B_MSIL1C_20181106T185559_N0207_R113_T10SFJ_20181106T204800/S2B_MSIL1C_20181106T185559_N0207_R113_T10SFJ_20181106T204800.SAFE/GRANULE/L1C_T10SFJ_A008719_20181106T190027/IMG_DATA/T10SFJ_20181106T185559_B12.jp2")
PrefireB122 <- raster("Data/Sentinel2/Prefire/S2B_MSIL1C_20181106T185559_N0207_R113_T10TFK_20181106T204800/S2B_MSIL1C_20181106T185559_N0207_R113_T10TFK_20181106T204800.SAFE/GRANULE/L1C_T10TFK_A008719_20181106T190027/IMG_DATA/T10TFK_20181106T185559_B12.jp2")


###Postfire Image from the 6th of December at 18:57:49 PM during relative Orbit 113###

##Postfire 2 Tiles Band8##

PostfireB81 <- raster("Data/Sentinel2/Postfire/S2B_MSIL1C_20181206T185749_N0207_R113_T10SFJ_20181206T203841/S2B_MSIL1C_20181206T185749_N0207_R113_T10SFJ_20181206T203841.SAFE/GRANULE/L1C_T10SFJ_A009148_20181206T185746/IMG_DATA/T10SFJ_20181206T185749_B08.jp2")
PostfireB82 <- raster("Data/Sentinel2/Postfire/S2B_MSIL1C_20181206T185749_N0207_R113_T10TFK_20181206T203841/S2B_MSIL1C_20181206T185749_N0207_R113_T10TFK_20181206T203841.SAFE/GRANULE/L1C_T10TFK_A009148_20181206T185746/IMG_DATA/T10TFK_20181206T185749_B08.jp2")

##Postfire 2 Tiles Band12##

PostfireB121 <- raster("Data/Sentinel2/Postfire/S2B_MSIL1C_20181206T185749_N0207_R113_T10SFJ_20181206T203841/S2B_MSIL1C_20181206T185749_N0207_R113_T10SFJ_20181206T203841.SAFE/GRANULE/L1C_T10SFJ_A009148_20181206T185746/IMG_DATA/T10SFJ_20181206T185749_B12.jp2")
PostfireB122 <- raster("Data/Sentinel2/Postfire/S2B_MSIL1C_20181206T185749_N0207_R113_T10TFK_20181206T203841/S2B_MSIL1C_20181206T185749_N0207_R113_T10TFK_20181206T203841.SAFE/GRANULE/L1C_T10TFK_A009148_20181206T185746/IMG_DATA/T10TFK_20181206T185749_B12.jp2")

####Mosaic####

##Prefire Mosaic for the 2 Tiles in Band 8 and 12##

Prefireband8<- mosaic(PrefireB81,PrefireB82, fun="max")
Prefireband12<-mosaic(PrefireB121,PrefireB122, fun="max")

##Postfire Mosaic for the 2 Tiles in Band 8 and 12##

Postfireband8<-mosaic(PostfireB81,PostfireB82, fun="max")
Postfireband12<- mosaic(PostfireB121,PostfireB122, fun="max")

####Resamle####

##Resample Band 8 for Pre and Postfire Image to a 20x20m Pixelsize so that it is the same as Band 12##

repreband8<-resample(Prefireband8, Prefireband12, method='bilinear')
repostband8<- resample(Postfireband8, Postfireband12, method='bilinear')

####Crop####

###Load Shapefile for Fireperimeter, provided by USFS

fireperimeter <- readOGR("C:/Users/Martin/Desktop/R_Course/Shapefile/Camp_perimeter.shp")

##Crop all Rasters to extent of Fireperimeter##

Cropreband12<- crop(Prefireband12, fireperimeter)
Cropreband8 <- crop(repreband8, fireperimeter)
Croppostband12 <- crop(Postfireband12, fireperimeter)
Croppostband8 <- crop(repostband8, fireperimeter)

####NBR####

###Normalized Burn Ratio for Sentinel 2 is calculated: Band 8 minus Band 12 over Band 8 + Band 12###

##Prefire NBR##

pre_fire_NBR<-(Cropreband8-Cropreband12)/(Cropreband8+Cropreband12)
plot(pre_fire_NBR)

##Postfire NBR##

post_fire_NBR<-(Croppostband8-Croppostband12)/(Croppostband8+Croppostband12)
plot(post_fire_NBR)

####dNBR###

###difference Normalized Burn Ratio created by subtracting the pre-fire NBR from the post-fire NBR raster###

dNBR <- (pre_fire_NBR) - (post_fire_NBR)
plot(dNBR)

#######If you want to Clip to fireperimeter####
dNBR_masked <- mask(dNBR,fireperimeter)
dNBR_cropped <- crop(dNBR_masked,fireperimeter)
plot(dNBR_cropped)

####Classes####

##scales the dNBR map##

dNBR_scaled <- 1000*dNBR_cropped

##sets the ranges that will be used to classify##

NBR_ranges <- c(-Inf, -500, -1, -500, -251, 1, -251, -101, 2, -101, 99, 3, 99, 269, 4, 269, 439, 5, 439, 659, 6, 659, 1300, 7, 1300, +Inf, -1)

##sets a classification matrix##

class.matrix <- matrix(NBR_ranges, ncol = 3, byrow = TRUE)

##classification matrix is used to classify dNBR_scaled##

dNBR_reclass <- reclassify(dNBR_scaled, class.matrix, right=NA)

####Legend####

##attribute table for the legend##

dNBR_reclass <- ratify(dNBR_reclass) 
rat <- levels(dNBR_reclass)[[1]]

##creates the text that will be on the legend##

rat$legend  <- c("NA", "Enhanced Regrowth, High", "Enhanced Regrowth, Low", "Unburned", "Low Severity", "Moderate-low Severity", "Moderate-high Severity", "High Severity") 
levels(dNBR_reclass) <- rat

##Set colours for severity classes##

my_col=c("white", "darkolivegreen","darkolivegreen4","limegreen", "yellow2", "orange2", "red", "purple")

##Plot Header##

plot(dNBR_reclass,col=my_col,legend=F,box=T,axes=T, main="Burn Severity \nCamp Fire, California \n8-25 Nov 2018 ") 

##Plot fireperimeter outline##
plot(fireperimeter, add = TRUE)

##Plots Legend##
legend(x='bottomright', legend =rat$legend, fill = my_col, y=4415000,cex = 0.59)