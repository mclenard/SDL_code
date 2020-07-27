library(tidyverse)
library(stringr)
library(lubridate)

plant_data <- read_csv("Plants DB 4_7.csv")

plant_data <- plant_data %>% mutate(type = "Event", 
                                    language = "en", 
                                    datasetName = "Ann Arbor Natural Area Preservation Plants Database",
                                    basisOfRecord = "HumanObservation",
                                    informationWithheld = "Observer identities withheld",
                                    continent = "North America",
                                    country = "United States",
                                    countryCode = "US",
                                    stateProvince = "Michigan",
                                    county = "Washtenaw",
                                    geodeticDatum = "NAD83",
                                    kingdom = "Plantae")

plant_data <- plant_data %>% mutate(occurrenceID = paste("AANAPPlants:", Observation_ID, sep = ""),
                                    verbatimLocality = paste(NA_Name, Co_Name, sep = " - "),
                                    eventDate = mdy(Date_Observed),
                                    taxonRank = ifelse(is.na(PLANT_ID), "Genus", "Species"),
                                    organismQuantity = case_when(
                                      Abundance == 1 ~ "Rare",
                                      Abundance == 2 ~ "Occasional",
                                      Abundance == 3 ~ "Common",
                                      Abundance == 4 ~ "Abundant"
                                    ),
                                    organismQuantityType = "AcforScale")

Ordered_plant_data <- plant_data %>% select(type, language, datasetName, basisOfRecord, informationWithheld,
                      occurrenceID,
                      organismQuantity, organismQuantityType,
                      occurrenceRemarks = Comments,
                      organismID = PLANT_ID,
                      eventDate,
                      verbatimEventDate = Date_Observed,
                      continent, country, countryCode, stateProvince, county,
                      verbatimLocality,
                      #geodeticDatum,
                      taxonID = Species_ID,
                      scientificName = SciNameTrimFix,
                      kingdom,
                      family = `FAMILY NAME`,
                      taxonRank,
                      vernacularName = `COMMON NAME`,
                      taxonRemarks = Notes)
                                    
write_csv(Ordered_plant_data, "NAP Plants Simple DwC.csv", na = "")
