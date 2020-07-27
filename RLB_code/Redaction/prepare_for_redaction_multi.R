library(tidyverse)

# Import the needed files, including the altered subjects file

subjects_filename <- ""
extractions_filename <- ""

subjects_data <- read_csv(subjects_filename)
extractions_data <- read_csv(extractions_filename)

# Join the subjects data with the reduced shape data, on subject ID

joined <- subjects_data %>% inner_join(extractions_data, by = "subject_id")

# Trim, rearrange & export .csv with columns in the 'right' order for redact_v3.py

for_export <- joined %>% select(subject_id, img_filename, img_url, 
                                `data.frame0.T6_tool0_x`, 
                                `data.frame0.T6_tool0_y`, 
                                `data.frame0.T6_tool0_width`, 
                                `data.frame0.T6_tool0_height`)

write_csv(for_export, "for_redaction_v3_13300.csv", col_names = FALSE)
