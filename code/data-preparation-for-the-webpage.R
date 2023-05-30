library(tidyverse)
library(readxl)

# the main NBL data =====
## load the data from the Excel file =====
holle_tb <- read_xlsx("data/stokhof_1980_holle_lists_v1.xlsx", 
                      sheet = 1, 
                      range = "A1:K1632") |> 
  select(-SortingIndex) |> 
  select(Index, 
         Dutch, 
         English, 
         Indonesian, 
         v1894, `v1904/1911`, v1931, 
         Swadesh, 
         Swadesh_orig = Swadesh_words_original, 
         remark)
## save the data as a tab-separated-value (.tsv) file =====
holle_tb |> 
  write_tsv("data/digitised-holle-list-in-stokhof-1980.tsv",
            na = "")

# the unindexed Swadesh list =====
read_xlsx("data/stokhof_1980_holle_lists_v1.xlsx", sheet = "swadesh-unindex") |> 
  pull(word) |> 
  write_lines("data/swadesh-unindexed-in-NBL.txt")

# the 1904/1911 version =====
holle_1904_tb <- read_xlsx("data/stokhof_1980_holle_lists_v1.xlsx", 
                           sheet = 4)
holle_1904_tb |> 
  write_tsv("data/digitised-holle-list-in-stokhof-1980-add-1904_1911.tsv",
            na = "")

# the 1931 version =====
holle_1931_tb <- read_xlsx("data/stokhof_1980_holle_lists_v1.xlsx", 
                           sheet = 3)
holle_1931_tb |> 
  write_tsv("data/digitised-holle-list-in-stokhof-1980-add-1931.tsv",
            na = "")

