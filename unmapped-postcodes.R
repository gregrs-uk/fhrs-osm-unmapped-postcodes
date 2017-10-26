library(tidyverse)

fhrs <- read_csv('fhrs.csv')
postcodes <- read_tsv('postcodes.tsv')

unmapped <- fhrs %>%
  left_join(postcodes, by=c('PostCode'='Postcode')) %>%
  filter(Mapped == 0) %>%
  select(PostCode, FHRSID, BusinessName) %>%
  mutate(Link = paste0('http://ratings.food.gov.uk/business/en-GB/', FHRSID),
         Region = sub('^([A-Z]{1,2}).*', '\\1', PostCode)) %>%
  arrange(PostCode)

quietly(
  unmapped %>% pull(Region) %>% unique() %>%
  map(function(x)
      unmapped %>%
      filter(Region == x) %>%
      select(-Region) %>%
      write_csv(file.path('output',paste0('fhrs-unmapped-postcodes-',x,'.csv')))
  )
)
