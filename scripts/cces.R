# Sophisticated Cynic

# Load libs
library(tidyverse)
library(car)
library(dplyr)
library(xtable)
library(ggplot2)

# se
se <- function(x) sd(x, na.rm = T)/sqrt(length(x[!is.na(x)]))

# Read in data
cces <- foreign::read.spss("../data/cces/UCM_CES2020_Unweighted_Data.sav", to.data.frame = T)

with(cces, table(AGTPolCynic_split, AGTPolCynic_AGTGoodBad_order))

cces$AGTPolCynic_pren <- car::recode(cces$AGTPolCynic_pre, "'Extremely Sophisticated' = 1; 
                                                    'Very Sophisticated' = .83; 
                                                    'Somewhat Sophisticated' = .66; 
                                                    'Neither Sophisticated Nor Unsophisticated' = .50; 
                                                    'Somewhat Unsophisticated' = .33; 
                                                    'Very Unsophisticated' = .16; 
                                                    'Extremely Unsophisticated' = 0")

cynic <- cces %>% 
  group_by(AGTPolCynic_split, AGTGoodBad_pre) %>%
  summarize(avg = mean(as.numeric(AGTPolCynic_pren), na.rm = T), 
            n = n(),
            std_error = sd(as.numeric(AGTPolCynic_pren), na.rm = T)/n())

# hidden republicans among ind. to interpret
  
parking <- cces %>% 
  group_by(pid3lean, UCMParking_split) %>%
  filter(!is.na(UCMParking_split)) %>%
  filter(pid3lean != "            ") %>%
  summarize(avg = mean(as.numeric(UCMParking), na.rm = T),
            med = median(as.numeric(UCMParking), na.rm = T),
            n = n(),
            std_error = se(as.numeric(UCMParking)))

print(
    xtable(error,
         digits = 1,
         caption = "Average Number of Errors", 
         label = "tab:error_sum"), 
      include.rownames = FALSE,
      include.colnames = TRUE, 
      floating = TRUE,
      type = "latex", 
      caption.placement = "bottom",
      table.placement = "!htb",
      file = "tabs/error_sum.tex")

print(
    xtable(parking,
         digits = 1,
         caption = "Average Number of Errors", 
         label = "tab:error_sum"), 
      include.rownames = FALSE,
      include.colnames = TRUE, 
      floating = TRUE,
      type = "latex", 
      caption.placement = "bottom",
      table.placement = "!htb",
      file = "tabs/parking_sum.tex")


