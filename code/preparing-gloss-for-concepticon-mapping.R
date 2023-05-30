# data preparation for testing the concepticon map_concepts function in terminal
df <- readr::read_tsv('data/digitised-holle-list-in-stokhof-1980.tsv')
df <- df[, "English"]
df <- subset(df, !is.na(English))
colnames(df) <- "GLOSS"
df$NUMBER <- 1:nrow(df)
filenames <- paste("Stokhof-1980-", nrow(df), ".tsv", sep = "")
readr::write_tsv(df, file = paste("data/", filenames, sep = ""))