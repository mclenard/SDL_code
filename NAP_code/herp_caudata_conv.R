library(tidyverse)
library(stringr)
library(lubridate)

cau_data <- read_csv("Caudata DB 5_2.csv")
coords <- read_csv("CaudataLatLong.csv")

cau_data <- cau_data %>% mutate(type = "Event", 
                                    language = "en", 
                                    datasetName = "Ann Arbor Natural Area Preservation Herp Database",
                                    basisOfRecord = "HumanObservation",
                                    informationWithheld = "Observer identities withheld | coordinate information not given for vulnerable species",
                                    continent = "North America",
                                    country = "United States",
                                    countryCode = "US",
                                    stateProvince = "Michigan",
                                    county = "Washtenaw",
                                    geodeticDatum = "NAD83",
                                    kingdom = "Animalia")

cau_data <- cau_data %>% filter(CaI_Num_Juvs > 0 | CaI_Num_Adults > 0 | CaI_Num_Eggmasses > 0)

cau_data <- cau_data %>% left_join(coords, by = c("CaI_Inv_ID_KEY" = "InvID_KEY"))

cau_data <- cau_data %>% mutate(occurrenceID = paste("AANAPCau:", CaI_Inv_ID_KEY, sep = ""),
                                    verbatimLocality = NA_Name,
                                    eventDate = mdy(CaV_Date),
                                    taxonRank = ifelse(is.na(Species_ID), "Genus", "Species"),
                                    organismQuantity = case_when(
                                      CaI_Num_Juvs > 0 & CaI_Num_Adults > 0 ~ CaI_Num_Juvs + CaI_Num_Adults,
                                      CaI_Num_Juvs > 0 & (CaI_Num_Adults == 0 | is.na(CaI_Num_Adults)) ~ CaI_Num_Juvs,
                                      CaI_Num_Adults > 0 & (CaI_Num_Juvs == 0 | is.na(CaI_Num_Juvs)) ~ CaI_Num_Adults,
                                      (CaI_Num_Adults > 0 | is.na(CaI_Num_Adults)) & (CaI_Num_Juvs == 0 | is.na(CaI_Num_Juvs)) ~ CaI_Num_Eggmasses),
                                    organismQuantityType = case_when(
                                      CaI_Num_Juvs > 0 & CaI_Num_Adults > 0 ~ "individuals",
                                      CaI_Num_Juvs > 0 & (CaI_Num_Adults == 0 | is.na(CaI_Num_Adults)) ~ "individuals",
                                      CaI_Num_Adults > 0 & (CaI_Num_Juvs == 0 | is.na(CaI_Num_Juvs)) ~ "individuals",
                                      (CaI_Num_Adults > 0 | is.na(CaI_Num_Adults)) & (CaI_Num_Juvs == 0 | is.na(CaI_Num_Juvs)) ~ "eggmasses"))


Ordered_cau_data <- cau_data %>% select(type, language, datasetName, basisOfRecord, informationWithheld,
                      occurrenceID,
                      organismQuantity, organismQuantityType,
                      occurrenceRemarks = CaI_Comments,
                      organismID = Species_ID,
                      eventDate,
                      verbatimEventDate = CaV_Date,
                      continent, country, countryCode, stateProvince, county,
                      verbatimLocality,
                      decimalLatitude = Lat,
                      decimalLongitude = Long,
                      geodeticDatum,
                      taxonID = Species_ID,
                      scientificName = Scientific_Name,
                      kingdom,
                      family = Family,
                      taxonRank,
                      vernacularName = Common_Name,
                      taxonRemarks = Comments)
                                    
write_csv(Ordered_cau_data, "NAP Caudata Simple DwC.csv", na = "")
