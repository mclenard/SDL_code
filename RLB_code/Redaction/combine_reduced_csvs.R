library(tidyverse)
library(stringr)

# Import the needed files

subjects_data <- read_csv("")
text_data <- read_csv("")
dropdown_data <- read_csv("")

# Widen the dropdown data so that all data for one subject is on one row

dropdown_wide <- dropdown_data %>%
  pivot_wider(names_from = task, values_from = data.value)

# Join .csvs on subject ID

combined <- subjects_data %>% inner_join(text_data, by = 'subject_id') %>%
  inner_join(dropdown_wide, by = 'subject_id')

# Trim & rename columns as needed (these are just suggestions)

combined <- combined %>% 
  select(-c(`metadata`, `locations`, `data.aggregation_version.x`, `data.aggregation_version.y`, 
            `workflow_id.x`, `workflow_id.y`, `task`, `reducer.x`, `reducer.y`,
            `retirement_reason`, `retired_at`)) %>%
  rename(Paleo1 = T1, Paleo2 = T2, Paleo3 = T3, Paleo4 = T4, Day = T8, Month = T9, Year = T10)

# Merge day, month and year columns into a "date" column for later
# Find and replace month codes

combined <- combined %>% mutate(Date = paste(str_sub(Day, 4, -7), str_sub(Month, 4, -7), str_sub(Year, 4, -7), sep = "-"))

combined <- combined %>% mutate_all(funs(str_replace_all(., "f8b03006b6c6a", "jan")))
combined <- combined %>% mutate_all(funs(str_replace_all(., "99db35c330b19", "feb")))
combined <- combined %>% mutate_all(funs(str_replace_all(., "97a97ded84917", "mar")))
combined <- combined %>% mutate_all(funs(str_replace_all(., "3c11bc64c7e6a", "apr")))
combined <- combined %>% mutate_all(funs(str_replace_all(., "f7fc8eb88835c", "may")))
combined <- combined %>% mutate_all(funs(str_replace_all(., "929aaab2effb4", "jun")))
combined <- combined %>% mutate_all(funs(str_replace_all(., "9a5043fe6caac", "jul")))
combined <- combined %>% mutate_all(funs(str_replace_all(., "3f8d0e6e8fc6c", "aug")))
combined <- combined %>% mutate_all(funs(str_replace_all(., "cb2494ddf3175", "sep")))
combined <- combined %>% mutate_all(funs(str_replace_all(., "1daeafd20e9e", "oct")))
combined <- combined %>% mutate_all(funs(str_replace_all(., "ef2ed27349047", "nov")))
combined <- combined %>% mutate_all(funs(str_replace_all(., "75e5e50ecbc3a", "dec")))

# Add row indicating whether or not a page has multiple paleontologists' notes present
# Note - this assumes you haven't yet found + replaced paleo name codes

combined <- combined %>% mutate(NumPaleo = ifelse(grepl('^.{13}$', Paleo2) & grepl('^.{13}$', Paleo3) & 
                                                    grepl('^.{13}$', Paleo4), "Single", "Multiple"))

# Write out combined data .csv
  
write_csv(combined, 'combined_data.csv')
