# This script reproduces Shaun McGirr's analysis for the Intercom Screener, 20-21 February 2016
# Dependencies: packages loaded below, data loaded from data_raw

# Program structure
# 1. Load data from zip files emailed to me
# 2. Make it ready for analysis
# 3. Explore visually to refine business questions
# 4. Analyse to answer business questions
# 5. Produce automated report

####################
# 0. Preliminaries #
####################

# library(XML)        #install.packages('XML')
# library(httr)       #install.packages('httr')
# library(downloader) #install.packages('downloader')
library(readr)      #install.packages('readr')
library(lubridate)  #install.packages('lubridate')
library(zoo)        #install.packages('zoo')
library(ggplot2)    #install.packages('ggplot2')
library(dplyr)      #install.packages('dplyr')
# library(ggmap)      #install.packages("ggmap")
library(Cairo)      #install.packages('Cairo')
library(tidyr)      #install.packages('tidyr')
library(knitr)      #install.packages('knitr')

options(digits = 15) # So display of numerics isn't truncated

##################
# 1. Obtain data #
##################

# Download assemble the two CSVs
source("code_grooming/assemble_intercom_data.R")

######################
# 2. Make data ready #
######################

# Build a data frame that will answer the questions posed in the exercise
source("code_analysis/subset_intercom_data.R")

#######################
# 3. Explore visually #
#######################

# Visualise
source("code_analysis/visualise_intercom_data.R")

#######################
# 4. Further analysis #
#######################

#

#####################
# 5. Compile report #
#####################

# knit('intercom-analysis-report.rnw', encoding='UTF-8') 
# system('pdflatex intercom-analysis-report.tex')
