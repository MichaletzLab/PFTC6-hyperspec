### Cleaning hyperspectral measurements 
library(data.table)
library(ggplot2)
library(spectrolab)
library(stringr)
library(tidyverse) 
library(MetBrewer)


## find the files to read
allfiles = list.files("./raw_data",
                      full.names = T,
                      recursive = T,
                      pattern = 'sig')

# loop through, read file, correct sensor overlap, return as data table
allspectra = rbindlist(lapply(allfiles, function(x){
  y = read_spectra(x)
  y2 = match_sensors(y, c(990,1900))
  return(as.data.table(y2))
}))

#remove white references
allspectra <- subset(allspectra, allspectra$"900" < 0.9) 

#replace periods with underscore for consistent delimiter in sample name
allspectra$sample_name <- gsub(".", "_", allspectra$sample_name, fixed = TRUE)
allspectra$sample_name <- gsub("-", "_", allspectra$sample_name, fixed = TRUE)


#pull site and turf IDs from sample name
allspectra[, c("site","turf") := tstrsplit(sample_name, "_", keep = c(2,3))]

#pull species ID from sample name
allspectra[, c("species") := tstrsplit(sample_name, "[0-9]_|_0", keep = c(3))]

unique(allspectra$site)
unique(allspectra$turf)

#standardizing species names
allspectra[species == "star_moss", species := "kindbergia_praelonga"]
allspectra[species %in% c("stachys_alpina","potentilla_erecta"), species := "veronica_alpina"]
allspectra[species %in% c("polygala_serpyllifolia"), species := "veronica_alpina"]
allspectra[species %in% c("achilea_millefolium","achilea_milllefolium"), species := "achillea_millefolium"]
allspectra[species %in% c("avenella_flexuosa","avanella_flexuosa"), species := "deschampsia_flexuosa"]
allspectra[species %in% c("alchemila_alpina", "alchemilla alpina"), species := "alchemilla_alpina"]
allspectra[species %in% c("correct_deschampsia"), species := "deschampsia_flexuosa"]
allspectra[species %in% c("hypericum"), species := "hypericum_maculatum"]
allspectra[species %in% c("new_alchemilla_alpina"), species := "alchemilla_alpina"]
allspectra[species %in% c("new_veronica_alpina"), species := "veronica_alpina"]
allspectra[species %in% c("vaccinium_vitis_idaea"), species := "vaccinium_vitis_idea"]
allspectra[species %in% c("agrostris_capillaris"), species := "agrostis_capillaris"]



#removing erroneous samples (could not ID, mixed samples), and any species with < 5 observations 
df2 <- allspectra[!(allspectra$species %in% c("agrostis_capillaris_x_luzula_multiflora","carex_ornithopodia","grass","moss","moss_",
                                              "alchemilla_vulgaris", "clavonia", "festuca_ovina","phleum_alpinum",
                                              "potentilla_repens","trifolium_repens")),]


allspectra<- df2
allspectra$rep <- str_sub(allspectra$sample_name,-6,-5)


#reorder columns
allspectra_ordered <- allspectra %>%
  select(rep, everything())
allspectra_ordered <- allspectra_ordered %>%
  select(turf, everything())
allspectra_ordered <- allspectra_ordered %>%
  select(site, everything())
allspectra_ordered <- allspectra_ordered %>%
  select(species, everything())
allspectra_ordered <- allspectra_ordered %>%
  select(species, everything())

#remove original sample name
allspectra_ordered = subset(allspectra_ordered, select = -c(sample_name) )
allspectra_ordered$species <- sub("^(\\w)(.*)", "\\U\\1\\L\\2", allspectra_ordered$species, perl = TRUE)
names(allspectra_ordered)[names(allspectra_ordered) == "site"] <- "siteID"
names(allspectra_ordered)[names(allspectra_ordered) == "turf"] <- "turf_number"
names(allspectra_ordered)[names(allspectra_ordered) == "rep"] <- "replicate"

#write dataset
write.csv(allspectra_ordered, "./hyperspectral_df.csv")

#table of sample sizes by species and site
table <- table(allspectra_ordered$species, allspectra_ordered$site)
table
write.csv(table, "./sample_size_table.csv") 

