library(tidyverse)
library(stringr)
library(lubridate)

lm_data <- read_csv("LepMam DB 4_11.csv")

lm_data <- lm_data %>% mutate(type = "Event", 
                                    language = "en", 
                                    datasetName = "Ann Arbor Natural Area Preservation Lep & Mammal Database",
                                    basisOfRecord = "HumanObservation",
                                    informationWithheld = "Observer identities withheld",
                                    continent = "North America",
                                    country = "United States",
                                    countryCode = "US",
                                    stateProvince = "Michigan",
                                    county = "Washtenaw",
                                    geodeticDatum = "NAD83",
                                    kingdom = "Animalia")

lm_data <- lm_data %>% mutate(occurrenceID = paste("AANAPLepMam:", Observation_ID, sep = ""),
                                    verbatimLocality = NA_Name,
                                    eventDate = mdy(Date_Observed),
                                    taxonRank = ifelse(is.na(Species_ID), "Genus", "Species"),
                                    organismQuantity = Abundance,
                                    organismQuantityType = "individuals")

Ordered_lm_data <- lm_data %>% select(type, language, datasetName, basisOfRecord, informationWithheld,
                      occurrenceID,
                      organismQuantity, organismQuantityType,
                      occurrenceRemarks = Observations_Comments,
                      organismID = Species_ID,
                      eventDate,
                      verbatimEventDate = Date_Observed,
                      continent, country, countryCode, stateProvince, county,
                      verbatimLocality,
                      locationRemarks = Natural_Area_Comments,
                      #geodeticDatum,
                      taxonID = Species_ID,
                      scientificName = Scientific_Name,
                      kingdom,
                      family = Family,
                      taxonRank,
                      vernacularName = Common_Name,
                      taxonRemarks = tblALLSpecies_Comments)
                                    
write_csv(Ordered_lm_data, "NAP LepMam Simple DwC.csv", na = "")
