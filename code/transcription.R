library(googlesheets4)
library(stringi)
library(tidyverse)

holle_transcription <- read_sheet(ss = "https://docs.google.com/spreadsheets/d/1Uj7wTOHLOGs53sL9Mu6pSTOpuUMWMYXbaPe7cVWYsHQ/edit#gid=0")

# colnames(holle_transcription)[3:4] <- c("example_remarks", "phonetic")

holle_transcription <- holle_transcription |> 
  rename(`Example/Remarks` = `Examples and Remarks Given in the Introductions`,
         `Approx. Phonetic Sym.` = `Approximate Phonetic Symbols`)

holle_transcription1 <- holle_transcription |> 
  # mutate(across(where(is.character), ~stri_trans_nfc(.))) |> 
  mutate(`Approx. Phonetic Sym.` = str_replace_all(`Approx. Phonetic Sym.`, "[\\[\\]]", "")) |> 
  select(ed_1894_1904_1911, ed_1931, `Approx. Phonetic Sym.`, `Example/Remarks`, My_notes) |> 
  mutate(across(where(is.character), ~replace_na(., ""))) |> 
  rename(`v1894/1901/1911` = ed_1894_1904_1911,
         `v1931` = ed_1931)

holle_transcription1 |> 
  write_csv("data/nbl_transcription_table.csv",
            na = "")
holle_transcription1 |> 
  write_rds("data/nbl_transcription_table.rds")
