### house keeping -----------------------------------------------------------

# clean enviroment
rm(list = ls())

# load proxy fun
source(file = "\\\\yfh352fs\\x952084$\\R\\proxy_script.R")

# exe proxy fun
fun_set_proxy(un = username,
              pw = password)

source(file = "\\\\yfh352fs\\x952084$\\R\\greenbelt\\fun_GET_data.R")

# load relevant libraries
library(tidyverse)

# set useragent
ua <- "https://github.com/EFT-Defra"

# set options
options(stringsAsFactors = FALSE)

# list_RData <- list.files(pattern = "wm_sf.RData")
# 
# for (i in list_RData){
#   load(i)
  # assign(gsub(pattern = ".RData",
  #             replacement = "",
  #             x = i),
  #        sf)
#}

## get region dataset ------------------------------------------------------

# rgn_wm_sf <- fun_geojson_sf(geojson = "https://opendata.arcgis.com/datasets/1b784deec90c46358c7a074aef8d3211_0.geojson",
#                             crs = 4326,
#                             subset_type = "non_geo",
#                             subset_col = rgn18nm,
#                             subset_val = "West Midlands",
#                             dsn = "context_layers.gpkg",
#                             layer = "Regions (December 2018) EN BFE")

rgn_wm_sf <- sf::read_sf("context_layers.gpkg")


# Natural England data ----------------------------------------------------

datasets <- read.csv("datasets.csv")

n <- dim(datasets)[1]

for (i in (35:n)){
  
  if (datasets$ingest[i] == 1){
  
  message("Acquiring ",datasets$dataset.title[i]," dataset")
  
  assign(paste0(datasets$dataset_code[i],"_wm_sf"),
         fun_geojson_sf(geojson = datasets$geojson[i],
                        crs = 4326,
                        subset_type = "geo",
                        subset_fun = "st_within",
                        subset_val = rgn_wm_sf,
                        dsn = paste0(datasets$theme[i],"_layers.gpkg"),
                        layer = datasets$dataset.title[i])
         )
  
  message(datasets$dataset.title[i]," dataset acquired")
  
  message("Removing variable ",paste0(datasets$dataset_code[i],"_wm_sf")," from environment")
  
  rm(list = (paste0(datasets$dataset_code[i],"_wm_sf")))
  
  # message("Acquiring ",datasets$dataset.title[i]," metadata")
  # 
  # assign(paste0(datasets$dataset_code[i],
  #               "_metadata"),
  #        fun_metadata(url = datasets$xml_base[i],
  #                     path = datasets$xml_path[i],
  #                     useragent = ua,
  #                     save = TRUE,
  #                     file = paste0(datasets$dataset_code[i]
  #                                   ,"_metadata.xml")
  #        )
  # )
  # 
  # message(datasets$Dataset.Title[i]," metadata acquired")
  # 
  # message("Removing variable ",paste0(datasets$code[i],"_metadata")," from environment")
  # 
  # rm(list = (paste0(datasets$code[i],"_metadata")))
  
  }
}


