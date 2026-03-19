#' -------------------------------------------------------------------------
#' Author: Betina Schneider
#' Contact: [betina.schneider@dpird.wa.gov.au]
#' Date: Mar 2026
#' Title: test of using Weather API
#' Outline: ...
#'
#' Details

#' Resources:
#'    - Manually source locations of BoM sites --> https://www.bom.gov.au/climate/cdo/about/sitedata.shtml

#' Version:
#'  

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

#--> API keys ####
readRenviron("~/.Renviron")
DPIRD_API_KEY <- Sys.getenv("DPIRD_KEY")
#####

#### 1. Station metadata ####
#--> Fetch all active DPIRD stations with rich metadata ####
stations_all <- get_stations_metadata(
  which_api      = "dpird",
  api_key        = DPIRD_API_KEY,
  include_closed = FALSE,
  rich           = TRUE
)

stations_all$station_name %>% unique()

stations_all %>% filter(station_name == "Cowalellup")


# 1) Find Cowalellup in your metadata table
cowalellup <- stations_all %>%
  filter(str_to_lower(station_name) == "cowalellup")

cowalellup %>% View()

cowalellup %>% str()

# getNamespaceExports("stringr")
getNamespaceExports("weatherOz")
getNamespaceExports("lubridate")

help(get_dpird_minute)

minutes_dif <- as.integer(as.numeric(difftime(end_date_02, start_date_02, units = "mins")))

a<-0
a

# for (i in 1:100){
#   print(i/5)
#   #modulus
#   if (i%%5 == 1){
#     a <- i
#     print(paste0("this is a magical number: ", a))
#   }

# }


lubridate::ymd_hms("2025-07-17 00:00:00", tz = "Australia/Perth")

datevec <- lubridate::ymd("2025-07-17") + lubridate::duration(c(0:1), units = "days")


df_list <- list()

# for (usedate in datevec){
for (i in 1:length(datevec)){
  
  ### test ####
  # i<-1
  #############

  usedate <- datevec[i]
  usedate_str <- paste0(usedate %>% as.character(), " 00:00:00")

  df_list[[i]] <- get_dpird_minute(
    station_code = cowalellup$station_code,
    start_date_time	= usedate_str,
    minutes = 1440L,
    values = "all",
    api_key = DPIRD_API_KEY
  )

  print(paste0("Data collected for date: ", datevec[i]))

} #end for loop

df_list %>% length()
df_list %>% str()


#' combine
#' time series plot
#' time vs temp
#' time vs humidity
#' superimosed plot with two vertical axes



help(get_dpird_minute)



period_02 <-get_dpird_minute(
  station_code = cowalellup$station_code,
  start_date_time = start_date_02,
  minutes = minutes_dif,
  api_key = DPIRD_API_KEY
)

cowalellup_minute <- bind_rows(period_01, period_02) %>%
  arrange(date_time)

cowalellup_minute
