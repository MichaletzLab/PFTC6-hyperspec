### Plotting average spectra by species
library(rcartocolor)

## renaming columns to include leading characters
lambda_names = names(allspectra)[grep("[0-9]",names(allspectra))]
setnames(allspectra, lambda_names, paste0("l_",lambda_names))
lambda_names = names(allspectra)[grep("[0-9]",names(allspectra))]

### calculate each wavelength's species-specific means/standard errors
for(x in lambda_names){
  allspectra[,paste0("m",x) := mean(get(x)), by = c("species")]
  allspectra[,n := .N, by = c("species")]
  allspectra[,sd := sd(get(x)), by = c("species")]
  allspectra[,paste0("se",x) := sd/sqrt(n), by = c("species")]
}
# ditch sample_name, got what we needed
allspectra[,sample_name := NULL]

# melt to make a long table
allmelt = melt(allspectra, id.vars = c("species"))

# isolate wavelengths and metrics 
allmelt[,lambda := tstrsplit(variable,"_",keep = 2)]
allmelt[,lambda := as.numeric(lambda)]
allmelt[,lev := tstrsplit(variable,"_",keep=1)]

## filter lev for the mean and standard errors
allmelt = unique(allmelt[lev %in% c("ml","sel"),])
allmelt[, variable := NULL]

#add standard error as another column
allwide = dcast(allmelt, 
                species + lambda ~ lev ) 

#filter out wavelegnths below 350nm for plotting (very low signal:noise)
allwide = subset(allwide, lambda > 400)
allwide$ml <- as.numeric(allwide$ml)
allwide$sel <- as.numeric(allwide$sel)

#plot most abundant species in dataset as example
speciesplot <- ggplot(data = unique(allwide[species %in% c("achillea_millefolium",
                                                                 "alchemilla_alpina",
                                                                 "vaccinium_vitis_idea"),
                                                   .(species,lambda,ml,sel)]),
                             aes(x = lambda, color = species, fill = species)) +
  geom_ribbon(aes(ymin = 100*(ml-2*sel), ymax = 100*(ml+2*sel), fill = species), alpha = 0.3, color = NA) +
  ylab("% Reflectance") + 
  xlab("Wavelength (nm)") +
  geom_line(aes(y = 100*ml)) + 
  scale_fill_carto_d(name = "Species", palette = "Vivid") +
  scale_color_carto_d(name = "Species", palette = "Vivid") +
  theme_classic()
speciesplot
ggsave("example_spectra.pdf", speciesplot, units = "mm", width = 200, height = 100)

