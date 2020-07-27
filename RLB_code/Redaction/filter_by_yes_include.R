library(tidyverse)

# Read in reduced question data & classification data

question_reduction <- read_csv("")

classifications <- read_csv("")

# Filter reduced question data to only include subjects that were marked "Yes, this should be included"

question_yes <- question_reduction %>% filter(!is.na(data.yes))

# Filter classification data to only include classifications from the current workflow

classifications_current <- classifications %>% filter(workflow_id == 13300)

# Filter classification data to only include the above-mentioned subjects 
# via an inner join to filtered question data

classifications_yes <- classifications_current %>%
  inner_join(question_yes, by = c('subject_ids' = 'subject_id'))

# Since we no longer need the question data columns post-join, we can drop them with a select()
# We also need to restore a column name that was altered by the join

classifications_yes <- classifications_yes %>%
  select(c(1:14)) %>% rename(workflow_id = workflow_id.x)

# Write out .csv of classification data that only includes "yes" rows

write_csv(classifications_yes, "")
