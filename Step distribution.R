library(sp)
library(spdep)
library(rgeos)
library(rgdal)
library(raster)
library(maptools)
library(broom)
library(MASS)

###Damien added something here
## emily added something
load(file = "./parents_95_nt.rdata")
load(file = "./pups_95_nt.rdata")

#Distance between natal HR and adult HR
dd <- lapply(1:39, function(z){
  center1 = gCentroid(parents_95_nt[z,])
  center2 = gCentroid(pups_95_nt[z,])
  dist = gDistance(center1, center2)
  return(dist)
  })

#Format distance data
dist <- as.data.frame(dd)
dist <- t(dist)
dist <- as.numeric(dist)
hist(dist)
save(dist, file = "./dispersal_distance.rdata")

###Load the shapefile with the homerange polygons you care about
load(file = "./pups_95_nt.rdata")

##If you need to change the CRS, I recommend workign in UTMs
#Homerange_polys <- spTransform(Homerange_polys, CRS("YOUR CRS"))

#load your a vector with your step lengths/disersal distances
load(file = "./dispersal_distance.rdata")

##create a list of the names of the distributions you are going to fit your step data to
dists=c("cauchy", "exponential", "gamma",  "log-normal", "logistic", "normal", "Poisson", "t", "weibull")

##loop to test all of them and store AIC and BIC in data frame
testDist=c()
for (i in 1:9){
  testDist[i]=list(broom::glance(MASS::fitdistr(na.omit(dist[dist>0]),densfun=dists[i])))
  testDist[[i]]$distribution=dists[i]
}
library(plyr)
testDist <- ldply(testDist, data.frame)
testDist=testDist[order(testDist$AIC),] ##sort the dataframe so the best model is always listed first
testDist
fitDist=fitdistr(na.omit(dist[dist>0]),densfun=testDist$distribution[1]) ##fit your data to the winning distribution to get the parameters
