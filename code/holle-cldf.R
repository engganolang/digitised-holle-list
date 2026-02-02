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

# join the concepticon into the HNBL table
holle_tb_all <- holle_tb |> 
  left_join(concepticon)

# processing the glosses for the unspecified Dutch glosses
nogloss <- holle_tb_all |> 
  filter(str_detect(Index, "\\/|\\-")) |> 
  mutate(Index2 = Index) |>  
  separate_longer_delim(Index2, "/") |> 
  mutate(Index2 = str_replace(Index2, "-", ":"))

seq_gloss <- str_which(nogloss$Index2, ":")

for (i in seq_along(seq_gloss)) {
  
  gloss_range <- eval(parse(text = nogloss$Index2[seq_gloss[i]]))
  
  nogloss$Index2[seq_gloss[i]] <- str_c(gloss_range, collapse = ",")
  
  cat(seq_gloss[i], sep = "\n")
  
}

nogloss1 <- nogloss |> 
  separate_longer_delim(Index2, ",")

holle_tb_all2 <- holle_tb_all |> 
  rename(Index2 = Index,
         Dutch2 = Dutch,
         English2 = English,
         Indonesian2 = Indonesian) |> 
  select(Index2, Dutch2, English2, Indonesian2)

nogloss2 <- nogloss1 |> 
  left_join(holle_tb_all2) |> 
  # group_by(Index) |> 
  # mutate(English = str_c(str_c(English2, " [ID_", Index2, "]", sep = ""), collapse = "; "), 
  #        Indonesian = str_c(str_c(Indonesian2, " [ID_", Index2, "]", sep = ""), collapse = "; ")) |> 
  # ungroup()
  mutate(Indonesian = Indonesian2,
         English = English2)
rm(holle_tb_all2)

nogloss3 <- nogloss2 |> 
  select(Index, Dutch3 = Dutch2, English3 = English, Indonesian3 = Indonesian,
         Combined_Index_Being_Separated = Index2) |> 
  distinct()

holle_tb_all2 <- holle_tb_all |> 
  left_join(nogloss3) |> 
  distinct() |> 
  mutate(English = if_else(str_detect(Index, "(\\/|\\-)"),
                           English3,
                           English),
         Indonesian = if_else(str_detect(Index, "(\\/|\\-)"),
                           Indonesian3,
                           Indonesian)) |> 
  rename(Dutch_in_single_ID = Dutch3) |> 
  select(-English3, -Indonesian3)

## Add the concepticon for the unspecified glosses from the component concepticon gloss (if available)
concepts_tb <- concepticon |> 
  filter(Index %in% holle_tb_all2$Combined_Index_Being_Separated[!is.na(holle_tb_all2$Combined_Index_Being_Separated)]) |> 
  rename(Combined_Index_Being_Separated = Index,
         Concepticon_ID_2 = Concepticon_ID,
         Concepticon_Gloss_2 = Concepticon_Gloss)

holle_tb <- holle_tb_all2 |> 
  left_join(concepts_tb) |> 
  mutate(Concepticon_ID = if_else(!is.na(Combined_Index_Being_Separated),
                                  Concepticon_ID_2,
                                  Concepticon_ID),
         Concepticon_Gloss = if_else(!is.na(Combined_Index_Being_Separated),
                                     Concepticon_Gloss_2,
                                     Concepticon_Gloss)) |> 
  select(-Concepticon_ID_2, -Concepticon_Gloss_2) |> 
  distinct() |> 
  ### trim whitespace in unspecified marker <unsp.> in the Dutch glosses
  mutate(Dutch = str_replace_all(Dutch, "(\\<)\\s(?=unsp)", "\\1")) |> 
  mutate(Dutch = str_replace_all(Dutch, "\\s\\>", ">"))


# split the Dutch and Indonesian lists
holle_tb_nl <- holle_tb |> 
  select(Holle_ID = Index, Form = Dutch, English, Swadesh, Concepticon_ID, Concepticon_Gloss, Combined_Index_Being_Separated, Dutch_in_single_ID) |> 
  mutate(Language_ID = "nl")
holle_tb_id <- holle_tb |> 
  select(Holle_ID = Index, Form = Indonesian, English, Swadesh, Concepticon_ID, Concepticon_Gloss, Combined_Index_Being_Separated, Dutch_in_single_ID) |> 
  mutate(Language_ID = "id")

# combine the Dutch and Indonesian lists
holle_tb_all <- bind_rows(holle_tb_id, holle_tb_nl) |> 
  mutate(Source = "holleli1980") |> 
  distinct() |> 
  mutate(Form = str_replace_all(Form, "\\s{2,}", " ")) |> 
  mutate(Dutch_in_single_ID = str_replace_all(Dutch_in_single_ID, "\\s{2,}", " "))
holle_tb_all <- holle_tb_all |> 
  mutate(ID = 1:nrow(holle_tb_all),
         Parameter_ID2 = Combined_Index_Being_Separated,
         Parameter_ID2 = if_else(is.na(Parameter_ID2), Holle_ID, Parameter_ID2),
         Parameter_ID = paste(Parameter_ID2, "_", Concepticon_Gloss,
                              sep = "")) |> 
  relocate(ID, .before = Holle_ID) |> 
  select(-Parameter_ID2)

# CLDF - create the FormTable
cldf_form <- holle_tb_all |> 
  select(ID, Holle_ID, Language_ID, Parameter_ID, Form, English, 
         
         # this column (Collapsed_Holle_ID_Being_Separated) records the Indexes of the Holle's New Basic List that are
         # originally collapsed into the format such as ID-ID or ID/ID in Stokhof (1980), that are
         # in this CLDF database are splitted to carry the Glosses of the Individual, un-collapsed IDs
         Collapsed_Holle_ID_Being_Separated = Combined_Index_Being_Separated, 
         
         # this column (Dutch_in_Single_Holle_ID) records the individual Dutch glosses
         # that are part of the collapsed glosses and Indexes in Stokhof (1980)
         Dutch_in_Single_Holle_ID = Dutch_in_single_ID, 
         
         Swadesh, Source) |> 
  distinct()
nrow(cldf_form)
cldf_form |> write_excel_csv("cldf/forms.csv")

# CLDF - create the Parameter table
cldf_param <- holle_tb_all |> 
  select(ID = Parameter_ID, Name = English, Concepticon_Gloss, Concepticon_ID) |> 
  distinct()
cldf_param
nrow(cldf_param)
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
