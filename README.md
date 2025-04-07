# PFTC6 data paper README file (dataset iii)

This repository contains the cleaning code for the handheld hyperspectral measurements (dataset iii) from the data paper: Vandvik et al. Plant trait, carbon flux, reflectance and climate data from global change experiments and gradients in Norway.

**This repository contains:**

- raw data 

- code to clean the data and create clean data files

- code to create tables and figures showing sample sizes at each site, and variation in hyperspectral reflectance across sites, species and wavelengths

### Reproduce the cleaning code


To reproduce the cleaning code follow these steps:

1.  Clone this GitHub repository to your local machine.

2.  Run `renv::restore()` to reproduce the environment and download and
    install all R packages that are needed.

3.  Open the `run.R` file and run `library(targets)` and
    `targets::tar_make()` to reproduce the code.
