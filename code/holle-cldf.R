# code to generate CLDF dataset from the NBL
## the form table will consist of forms of the different language (Dutch, English, and Indonesian)
## the language table will consist of metadata for three languages: Dutch, English, and Indonesian)
library(tidyverse)

# read the Holle’s New Basic List (HNBL)
holle_tb <- read_tsv("data/digitised-holle-list-in-stokhof-1980.tsv")

# read the Concepticon for the HNBL
concepticon <- read_tsv("data/concepticon-mapping.tsv") |> 
  rename(Index = NUMBER,
         Concepticon_Gloss = CONCEPTICON_GLOSS,
         English = GLOSS,
         Concepticon_ID = CONCEPTICON_ID) |> 
  select(-SIMILARITY, -CHECKED)

# split the Dutch and Indonesian lists
holle_tb_nl <- holle_tb |> 
  select(Index, Dutch, English, Swadesh) |> 
  mutate(Language_ID = "nl")
holle_tb_id <- holle_tb |> 
  select(Index, Indonesian, English, Swadesh) |> 
  mutate(Language_ID = "id")

# combine the Concepticon with the Dutch and Indonesian lists
holle_tb_nl <- holle_tb_nl |> 
  filter(!is.na(English)) |> 
  left_join(concepticon |> select(-English), by = "Index") |> 
  rename(Holle_ID = Index,
         Form = Dutch)
holle_tb_id <- holle_tb_id |> 
  filter(!is.na(English)) |> 
  left_join(concepticon |> select(-English), by = "Index") |> 
  rename(Holle_ID = Index,
         Form = Indonesian)

# combine the Dutch and Indonesian lists
holle_tb_all <- bind_rows(holle_tb_id, holle_tb_nl) |> 
  mutate(Source = "holleli1980")
holle_tb_all <- holle_tb_all |> 
  mutate(ID = 1:nrow(holle_tb_all),
         Parameter_ID = paste(ID, "-", Language_ID, "-", Concepticon_Gloss,
                              sep = ""))

# CLDF - create the FormTable
cldf_form <- holle_tb_all |> 
  select(ID, Holle_ID, Language_ID, Parameter_ID, Form, English, Swadesh, Source)
cldf_form |> write_excel_csv("cldf/forms.csv")

# CLDF - create the Parameter table
cldf_param <- holle_tb_all |> 
  select(ID = Parameter_ID, Name = English, Concepticon_Gloss, Concepticon_ID)
cldf_param
cldf_param |> write_excel_csv("cldf/parameters.csv")

# CLDF - create the Language table
cldf_lang <- tibble(ID = c("id", "nl"),
                    Name = c("Indonesian", "Dutch"),
                    Glottocode = c("indo1316", "dutc1256"),
                    Glottolog_Name = c("Standard Indonesian", "Dutch"),
                    ISO639P3code = c("ind", "nld"),
                    Macroarea = c("Papunesia", "Eurasia"),
                    Latitude = c(-7.33, 52.00),
                    Longitude = c(109.72, 5.00),
                    Family = c("Austronesian", "Indo-European"))
cldf_lang |> write_excel_csv("cldf/languages.csv")