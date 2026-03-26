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


# getNamespaceExports("stringr")
# getNamespaceExports("weatherOz")
# getNamespaceExports("lubridate")



datevec <- lubridate::ymd("2025-07-17") + lubridate::duration(c(0:1), units = "days")

df_list <- list()

# for (usedate in datevec){
for (i in 1:length(datevec)){
  
  # i<-1 ##test

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

names(df_list) <- as.character(datevec)

## Combining datevec in one table

cowalellup_data <- bind_rows(df_list) 

names(cowalellup_data)

View(cowalellup_data)

# cowalellup_filter_minutes

attr(cowalellup_data$date_time, "tzone")

start_time <- lubridate::ymd_hms("2025-07-17 04:00:00", tz = "Australia/Perth")
end_time   <- lubridate::ymd_hms("2025-07-18 13:00:00", tz = "Australia/Perth")

attr(cowalellup_data$date_time, "tzone")

filtered_data <- cowalellup_data %>%
  filter(
    date_time >= start_time &
    date_time <= end_time
  )

View(filtered_data)

# time series plot temp and humidity

line1 <- filtered_data$air_temperature
line2 <- filtered_data$relative_humidity
time <- filtered_data$date_time
 
#' time vs temp

plot(
  time,
  line1,
  type = "l",
  col = "blue",
  lwd = 1,
  xlab = "Date Time",
  ylab = "Air Temperature (°C)",
  main = "Temperature over Time"
)

#' time vs humidity

plot(
  time,
  line2,
  type = "l",
  col = "red",
  lwd = 1,
  xlab = "Date Time",
  ylab = "Relative Humidity",
  main = "Humidity over Timer"
)

#' superimosed plot with two vertical axes

par(mar = c(5, 4, 4, 5))  # increase right margin

plot(
  time,
  line1,
  type = "l",
  col = "blue",
  lwd = 2,
  xlab = "Date Time",
  ylab = "Air Temperature (°C)",
  main = "Temperature and Humidity"
)

par(new = TRUE)

plot(
  time,
  line2,
  type = "l",
  col = "red",
  lwd = 2,
  axes = FALSE,   # remove axes
  xlab = "",
  ylab = ""
)

axis(side = 4)
mtext("Relative Humidity (%)", side = 4, line = 2)

legend("bottomright",
       legend = c("Temperature", "Humidity"),
       col = c("blue", "red"),
       lty = 1,
       lwd = 2)


