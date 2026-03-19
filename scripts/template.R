#' -------------------------------------------------------------------------
#' Author: Stephen Bradshaw
#' Contact: [stephen.bradshaw@dpird.wa.gov.au]
#' Date: Dec 2025
#' Title: test of using Weather API
#' Outline: ...
#'
#' Details
#'    - TEST: Looks at importing, plotting, wind roses etc
#'    - SITING 10m: Creates ranked list of sites without 10m wind sensors in SW WA and interactive html
#'    - ...
#' 
#' Resources:
#'    - Manually source locations of BoM sites --> https://www.bom.gov.au/climate/cdo/about/sitedata.shtml
#'    - Can't use Silo here as it is gridded and is NOT sensor dependent
#'    
#'
#' Version:
#'  - v1.00 (20251204):
#' ------------------------------------------------------------------------- 

#%% Package / Library Requirements ####
rm(list=ls())

#%% Packages (not in environment) -------------------------------------------
list.of.packages <- c("magrittr", "tidyr", "dplyr", "stringr", "purrr"
                      , "rebus", "data.table", "lubridate"
                      
                      , "weatherOz"
                      , "circular"
                      , "ggforce"
                      , "openair" #for wind rose
                      , "scales"
                      , "ggridges"
                      , "lubridate"
                      , "usethis"
                      , "sf", "sp"
                      , "plotly"
                      , "rnaturalearth"
                      , "rnaturalearthdata"
                      , "viridis"
                      , "readr"
                      , "remotes"
                      )

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

#%% Libraries ---------------------------------------------------------------
req_packages <- list.of.packages 
sapply(req_packages,require, character.only = TRUE, quietly=TRUE)

rm(list.of.packages, new.packages)
#####

#### Edit Environment if required ####
# usethis::edit_r_environ()
#####


#### Housekeeping ####
#--> Set TZ ####
Sys.setenv(TZ = "Australia/Perth")

#--> Assign numCores ####
# numCores = detectCores()-2  # this will use all available cores minus 2

#--> Set Directories ####
# tmp_openFile <- dirname(rstudioapi::getActiveDocumentContext()$path) %>% str_split("/") %>% unlist() %>% tail(1)
# dirParent <- dirname(rstudioapi::getActiveDocumentContext()$path) %>% str_remove(tmp_openFile)
# rm(tmp_openFile)
# dirData <- paste0(dirParent, "data")
# dirScripts <- paste0(dirParent, "scripts")
# dirOutputs <- paste0(dirParent, "outputs")
# setwd(dirParent)
