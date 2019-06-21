#### Prep Work #### Working Libraries
library(readxl)
library(data.table)
library(stringr)
library(dplyr)
library(tidyverse)
library(tidytext)
library(mice)
library(caret)
library(Boruta)

# Set Working Directory #
setwd("XXX")

# Import Dataset #
GOT_Original_DF <- read_excel("GOT_character_predictions.xlsx")

#### Summary ####
summary(GOT_Original_DF)
## NA Values;
# title : 1008
# culture : 1269
# dateOfBirth : 1513 - not needed
# mother : 1925 - too many NA's
# father : 1920 - too many NA's
# heir : 1923 - too many NA's
# house : 427 spouse : 1670 - not needed
# isAliveMother : 1925 - too many NA's
# isAliveFather : 1920 - too many NA's
# isAliveHeir : 1923 - too many NA's
# isAliveSpouse : 1670
# age : 1513 - try MICE - PMM, if doesn't make sense delete

# Create Original and Working DF #
GOT <- GOT_Original_DF

#### House Vs. Last Name ####

## What are the houses?  GOT_houses <- as.data.frame(table(GOT$house))

#### Fixing Duplicate & Misspelled Houses ####
GOT[] <- lapply(GOT, function(x) replace(x, grep("Brotherhood without", x), "Brotherhood Without Banners"))

GOT[] <- lapply(GOT, function(x) replace(x, grep("brotherhood without", x), "Brotherhood Without Banners"))

GOT[] <- lapply(GOT, function(x) replace(x, grep("Baratheon of", x), "House Baratheon"))

GOT[] <- lapply(GOT, function(x) replace(x, grep("Bolton of", x), "House Bolton"))

GOT[] <- lapply(GOT, function(x) replace(x, grep("Dayne of", x), "House Dayne"))

GOT[] <- lapply(GOT, function(x) replace(x, grep("Brune of", x), "House Brune"))

GOT[] <- lapply(GOT, function(x) replace(x, grep("Farwynd of", x), "House Farwynd"))

GOT[] <- lapply(GOT, function(x) replace(x, grep("Flint of", x), "House Flint"))

GOT[] <- lapply(GOT, function(x) replace(x, grep("Fossoway of", x), "House Fossoway"))

GOT[] <- lapply(GOT, function(x) replace(x, grep("Frey of", x), "House Frey"))

GOT[] <- lapply(GOT, function(x) replace(x, grep("Goodbrother of", x), "House Goodbrother"))

GOT[] <- lapply(GOT, function(x) replace(x, grep("Harlaw of", x), "House Harlaw"))

GOT[] <- lapply(GOT, function(x) replace(x, grep("Kenning of", x), "House Kenning"))

GOT[] <- lapply(GOT, function(x) replace(x, grep("Lannister of", x), "House Lannister"))

GOT[] <- lapply(GOT, function(x) replace(x, grep("Royce of", x), "House Royce"))

GOT[] <- lapply(GOT, function(x) replace(x, grep("Tyrell of", x), "House Tyrell"))

GOT[] <- lapply(GOT, function(x) replace(x, grep("Vance of", x), "House Vance"))

#### House Vs. Last Name 2.0 ####
##Fill in Missing Houses ##
#Creating variable 'housematch' to check if lastname and house matches
GOT <- GOT %>% mutate(housematch = str_detect(GOT$name, gsub(" ", "|", GOT$house)))

## After exploration, creating variable 'birth_house' with more accurate houses##
GOT$birth_house <- GOT$house


#### Changing OG Houses According to Lastname and Marital Status ####
GOT$birth_house[GOT$name == "Byam Flint"] <- "House Flint"
GOT$birth_house[GOT$name == "Mallador Locke"] <- "House Locke"
GOT$birth_house[GOT$name == "Janos Slynt"] <- "House Slynt"
GOT$birth_house[GOT$name == "Galazza Galare"] <- "House  of Galare"
GOT$birth_house[GOT$name == "Willow Heddle"] <- "House Heddle"
GOT$birth_house[GOT$name == "Thoren Smallwood"] <- "House Smallwood"
GOT$birth_house[GOT$name == "Jaremy Rykker"] <- "House Rykker"
GOT$birth_house[GOT$name == "Alannys Harlaw"] <- "House Harlaw"
GOT$birth_house[GOT$name == "Gormon Tyrell"] <- "House Tyrell"
GOT$birth_house[GOT$name == "Tya Lannister"] <- "House Lannister"
GOT$birth_house[GOT$name == "Ben Plumm"] <- "House Plumm"
GOT$birth_house[GOT$name == "Samwell Tarly"] <- "House Tarly"
GOT$birth_house[GOT$name == "Perriane Frey"] <- "House Frey"
GOT$birth_house[GOT$name == "Brandon Stark (Shipwright)"] <- "House Stark"
GOT$birth_house[GOT$name == "Tristifer IV Mudd"] <- "House Mudd"
GOT$birth_house[GOT$name == "Tristifer V Mudd"] <- "House Mudd"
GOT$birth_house[GOT$name == "Aerys I Targaryen"] <- "House Targaryen"
GOT$birth_house[GOT$name == "Robb Stark"] <- "House Stark"
GOT$birth_house[GOT$name == "Medwick Tyrell"] <- "House Tyrell"
GOT$birth_house[GOT$name == "Torrhen Stark"] <- "House Stark"
GOT$birth_house[GOT$name == "Euron Greyjoy"] <- "House Greyjoy"
GOT$birth_house[GOT$name == "Aegon V Targaryen"] <- "House Targaryen"
GOT$birth_house[GOT$name == "Elia Martell"] <- "House Martell"
GOT$birth_house[GOT$name == "Aegon II Targaryen"] <- "House Targaryen"
GOT$birth_house[GOT$name == "Theon Stark"] <- "House Stark"
GOT$birth_house[GOT$name == "Galyeon of Cuy"] <- "House Cuy"
GOT$birth_house[GOT$name == "Willamen Frey"] <- "House Frey"
GOT$birth_house[GOT$name == "Tion Frey"] <- "House Frey"
GOT$birth_house[GOT$name == "Harrag Hoare"] <- "House Hoare"
GOT$birth_house[GOT$name == "Aegon IV Targaryen"] <- "House Targaryen"
GOT$birth_house[GOT$name == "Benjen Stark (Bitter)"] <- "House Stark"
GOT$birth_house[GOT$name == "Aegon I Targaryen"] <- "House Targaryen"
GOT$birth_house[GOT$name == "Aenys I Targaryen"] <- "House Targaryen"
GOT$birth_house[GOT$name == "Viserys I Targaryen"] <- "House Targaryen"
GOT$birth_house[GOT$name == "Brandon Stark (Burner)"] <- "House Stark"
GOT$birth_house[GOT$name == "Normund Tyrell"] <- "House Tyrell"
GOT$birth_house[GOT$name == "Lancel V Lannister"] <- "House Lannister"
GOT$birth_house[GOT$name == "Tommen Baratheon"] <- "House Baratheon"
GOT$birth_house[GOT$name == "Beric Dondarrion"] <- "House Dondarrion"
GOT$birth_house[GOT$name == "Hizdahr zo Loraq"] <- "House of Loraq"
GOT$birth_house[GOT$name == "Aerys II Targaryen"] <- "House Targaryen"
GOT$birth_house[GOT$name == "Harwyn Hoare"] <- "House Hoare"
GOT$birth_house[GOT$name == "Jaehaerys I Targaryen"] <- "House Targaryen"
GOT$birth_house[GOT$name == "Baelor I Targaryen"] <- "House Targaryen"
GOT$birth_house[GOT$name == "Genna Lannister"] <- "House Lannister"
GOT$birth_house[GOT$name == "Maegor I Targaryen"] <- "House Targaryen"
GOT$birth_house[GOT$name == "Masha Heddle"] <- "House Heddle"
GOT$birth_house[GOT$name == "Aegon III Targaryen"] <- "House Targaryen"
GOT$birth_house[GOT$name == "Balon Greyjoy"] <- "House Greyjoy"
GOT$birth_house[GOT$name == "Joffrey Baratheon"] <- "House Baratheon"
GOT$birth_house[GOT$name == "Daeron I Targaryen"] <- "House Targaryen"
GOT$birth_house[GOT$name == "Melwys Rivers"] <- "House Frey"
GOT$birth_house[GOT$name == "Dorren Stark"] <- "House Stark"
GOT$birth_house[GOT$name == "Benjen Stark (Sweet)"] <- "House Stark"
GOT$birth_house[GOT$name == "Daeron II Targaryen"] <- "House Targaryen"
GOT$birth_house[GOT$name == "Harren Hoare"] <- "House Hoare"
GOT$birth_house[GOT$name == "Viserys II Targaryen"] <- "House Targaryen"
GOT$birth_house[GOT$name == "Jaehaerys II Targaryen"] <- "House Targaryen"
GOT$birth_house[GOT$name == "Alysanne Targaryen"] <- "House Targaryen"
GOT$birth_house[GOT$name == "Stannis Baratheon"] <- "House Baratheon"
GOT$birth_house[GOT$name == "Omer Florent"] <- "House Florent"
GOT$birth_house[GOT$name == "Ellaria Sand"] <- "House Martell"
GOT$birth_house[GOT$name == "Daemon Sand"] <- "House Martell"
GOT$birth_house[GOT$name == "Jeyne Heddle"] <- "House Heddle"
GOT$birth_house[GOT$name == "Luceon Frey"] <- "House Frey"

# Updating 'housematch' and creating new DF
GOTv2 <- GOT %>% mutate(housematch = str_detect(GOT$name, gsub(" ", "|", GOT$birth_house)))


#### House vs. Last Name 3.0 #### Bastards? ##

# Create a variable 'bastard' with bastardly lastnames
GOTv2$bastard <- ifelse(grepl("Waters|Snow|Pyke|Rivers|Stone|Hill|Flowers|Storm|Sand",
  GOTv2$name), "1", "0")

# Manually Change tricky names
GOTv2$bastard[GOTv2$name == "Sandor Frey"] <- 0
GOTv2$bastard[GOTv2$name == "Stonehand"] <- 0
GOTv2$bastard[GOTv2$name == "Hugor of the Hill"] <- 0
GOTv2$bastard[GOTv2$name == "Stone Thumbs"] <- 0
GOTv2$bastard[GOTv2$name == "Ralf Stonehouse"] <- 0
GOTv2$bastard[GOTv2$name == "Stonesnake"] <- 0
GOTv2$bastard[GOTv2$name == "Sigfry Stonetree"] <- 0
GOTv2$bastard[GOTv2$name == "Sandor Clegane"] <- 0
GOTv2$bastard[GOTv2$name == "Triston of Tally Hill"] <- 0


#### Prominent Houses ####
#Imputing some of the prominent houses from info gained through Google
GOTv2$birth_house[GOT$name == "Luco Prestayn"] <- "House Prestayn"
GOTv2$birth_house[GOT$name == "Moredo Prestayn"] <- "House Prestayn"
GOTv2$birth_house[GOT$name == "Gyles III Gardener"] <- "House Gardener"
GOTv2$birth_house[GOT$name == "Garth XII Gardener"] <- "House Gardener"
GOTv2$birth_house[GOT$name == "Ferrego Antaryon"] <- "House Antaryon"
GOTv2$birth_house[GOT$name == "Jon Vance"] <- "House Vance"
GOTv2$birth_house[GOT$name == "Urron Greyiron"] <- "House Greyiron"
GOTv2$birth_house[GOT$name == "Portifer Woodwright"] <- "House Woodwright"
GOTv2$birth_house[GOT$name == "Lucantine Woodwright"] <- "House Woodwright"
GOTv2$birth_house[GOT$name == "Doran Martell"] <- "House Martell"


#### Great Houses ####
# Creating a variable 'greathouse', should reflect house or birthouse
GOTv2$greathouse <- ifelse(grepl("Arryn|Greyjoy|Lannister|Stark|Targaryen|Tully|
         Frey|Casterly|Mudd|Justman|Hoare|Durradon|Gardener|
         Baratheon|Martell|Bolton|Tyrell",
  GOTv2$birth_house) | grepl("Arryn|Greyjoy|Lannister|Stark|Targaryen|Tully|Frey|
         Casterly|Mudd|Justman|Hoare|Durradon|Gardener|
         Baratheon|Martell|Bolton|Tyrell",
  GOTv2$house), "1", "0")


#### Extinct Houses ####
# Extinct Houses ... These people are not updated are they?
GOTv2$extincthouse <- ifelse(grepl("Amber|Baelish|Baratheon|Blackfyre|Bolton|Brownbarrow|
         Cargyll|Casterly|Cole|Darry|Durradon|Durwell|Elliver|
         Frost|Gardener|Grayson|Greenwood|Greyiron|Harroway|
         Hoare|Hollard|Justman|Lothston|Martell|Mudd|Qoherys|
         Reyne|Strong|Tarbeck|Towers|Toyne|Tyrell|Whent",
  GOTv2$birth_house) | grepl("Amber|Baelish|Baratheon|Blackfyre|Bolton|Brownbarrow|
         Cargyll|Casterly|Cole|Darry|Durradon|Durwell|Elliver|
         Frost|Gardener|Grayson|Greenwood|Greyiron|Harroway|Hoare|
         Hollard|Justman|Lothston|Martell|Mudd|Qoherys|Reyne|
         Strong|Tarbeck|Towers|Toyne|Tyrell|Whent",
  GOTv2$house), "1", "0")

#### Something Went Wrong Along the way, Changing variable types ####
GOTv2 <- type.convert(GOTv2)

GOTv2$name <- as.character(GOTv2$name)
GOTv2$book1_A_Game_Of_Thrones <- as.factor(GOTv2$book1_A_Game_Of_Thrones)
GOTv2$book2_A_Clash_Of_Kings <- as.factor(GOTv2$book2_A_Clash_Of_Kings)
GOTv2$book3_A_Storm_Of_Swords <- as.factor(GOTv2$book3_A_Storm_Of_Swords)
GOTv2$book4_A_Feast_For_Crows <- as.factor(GOTv2$book4_A_Feast_For_Crows)
GOTv2$book5_A_Dance_with_Dragons <- as.factor(GOTv2$book5_A_Dance_with_Dragons)
GOTv2$male <- as.factor(GOTv2$male)
GOTv2$isAliveMother <- as.factor(GOTv2$isAliveMother)
GOTv2$isAliveFather <- as.factor(GOTv2$isAliveFather)
GOTv2$isAliveHeir <- as.factor(GOTv2$isAliveHeir)
GOTv2$isAliveSpouse <- as.factor(GOTv2$isAliveSpouse)
GOTv2$isMarried <- as.factor(GOTv2$isMarried)
GOTv2$isNoble <- as.factor(GOTv2$isNoble)
GOTv2$isAlive <- as.factor(GOTv2$isAlive)
GOTv2$housematch <- as.factor(GOTv2$housematch)
GOTv2$bastard <- as.factor(GOTv2$bastard)
GOTv2$greathouse <- as.factor(GOTv2$greathouse)
GOTv2$extincthouse <- as.factor(GOTv2$extincthouse)


#### Finishing off unknown Houses ####
GOTv2$house <- as.character(GOTv2$house)
GOTv2$house[is.na(GOTv2$house)] <- "Unknown"
GOTv2$house <- as.factor(GOTv2$house)
GOTv2$birth_house <- as.character(GOTv2$birth_house)
GOTv2$birth_house[is.na(GOTv2$birth_house)] <- "Unknown"
GOTv2$birth_house <- as.factor(GOTv2$birth_house)
GOTv2$housematch <- as.character(GOTv2$housematch)
GOTv2$housematch[is.na(GOTv2$housematch)] <- "Unknown"
GOTv2$housematch <- as.factor(GOTv2$housematch)


#### Culture ####
## Lots of duplicate or misspelled cultures, should change it ##

# Changing the variable type so we can actually do something #
GOTv2$culture <- as.character(GOTv2$culture)

#### Fixing misspelled and duplicate cultures ####
GOTv2$culture[GOTv2$culture == "Andals"] <- "Andal"
GOTv2$culture[GOTv2$culture == "Asshai"] <- "Asshai'i"
GOTv2$culture[GOTv2$culture == "Astapor"] <- "Astapori"
GOTv2$culture[GOTv2$culture == "Braavos"] <- "Bravoosi"
GOTv2$culture[GOTv2$culture == "Dornish"] <- "Dornish"
GOTv2$culture[GOTv2$culture == "Dorne"] <- "Dornish"
GOTv2$culture[GOTv2$culture == "Wildling"] <- "Wildlings"
GOTv2$culture[GOTv2$culture == "Norvos"] <- "Norvoshi"
GOTv2$culture[GOTv2$culture == "Qarth"] <- "Qartheen"
GOTv2$culture[GOTv2$culture == "Ghiscaricari"] <- "Ghiscari"
GOTv2$culture[GOTv2$culture == "Lhazarene"] <- "Lhazareen"
GOTv2$culture[GOTv2$culture == "Lysene"] <- "Lyseni"
GOTv2$culture[GOTv2$culture == "Meereen"] <- "Meereenese"
GOTv2$culture[GOTv2$culture == "Riverlands"] <- "Rivermen"
GOTv2$culture[GOTv2$culture == "Stormlands"] <- "Stormlander"

GOTv2$culture[GOTv2$culture == "Free folk" | GOTv2$culture == "free folk"] <- "Free Folk"

GOTv2$culture[GOTv2$culture == "ironborn" | GOTv2$culture == "Ironmen"] <- "Ironborn"

GOTv2$culture[GOTv2$culture == "Northern mountain clans" | GOTv2$culture == "northmen"] <- "Northmen"

GOTv2$culture[GOTv2$culture == "Reach" | GOTv2$culture == "The Reach"] <- "Reachmen"

GOTv2$culture[GOTv2$culture == "Summer Isles" | GOTv2$culture == "Summer Islands"] <- "Summer Islander"

GOTv2$culture[GOTv2$culture == "Vale mountain clans" | GOTv2$culture == "Vale"] <- "Valemen"

GOTv2$culture[GOTv2$culture == "Westerlands" | GOTv2$culture == "westermen" | GOTv2$culture ==
  "Westerman" | GOTv2$culture == "Westeros"] <- "Westermen"

# Turning 'em back to factor as they should be #
GOTv2$culture <- as.factor(GOTv2$culture)

#### Titles ####
## Lots of Duplicate titles, should change that ##
# Changing the variable type so we can actually do something #
GOTv2$title <- as.character(GOTv2$title)

#### Fixing misspelled and duplicate titles ####
GOTv2$title[GOTv2$title == "[1]"] <- NA
GOTv2$title[GOTv2$title == "BrotherProctor"] <- "Brother"
GOTv2$title[GOTv2$title == "Karl's Hold"] <- "Karhold"
GOTv2$title[GOTv2$title == "Knight of Griffin's Roost"] <- "Knight"
GOTv2$title[GOTv2$title == "Magister of Pentos"] <- "Magister"
GOTv2$title[GOTv2$title == "Master of coin"] <- "Master of Coin"
GOTv2$title[GOTv2$title == "PrincessSepta"] <- "Princess"
GOTv2$title[GOTv2$title == "Master of whisperers"] <- "Master of Whisperers"


GOTv2$title[GOTv2$title == "Captain of the guard" | GOTv2$title == "Tradesman-Captain"] <- "Captain"

GOTv2$title[GOTv2$title == "BrotherProctor" | GOTv2$title == "Captain-General"] <- "Brother"

GOTv2$title[GOTv2$title == "Castellan of Harrenhal" | GOTv2$title == "CastellanCommander"] <- "Castellan"

GOTv2$title[GOTv2$title == "Commander of the City Watch" | GOTv2$title == "Commander of the Second Sons"] <- "Commander"

GOTv2$title[GOTv2$title == "Master of Deepwood Motte" | GOTv2$title == "Master of Harlaw Hall"] <- "Master"

GOTv2$title[GOTv2$title == "SerCastellan of Casterly Rock" | GOTv2$title == "Serthe Knight of Saltpans"] <- "Ser"

GOTv2$title[GOTv2$title == "King in the North" | GOTv2$title == "King of Astapor" |
  GOTv2$title == "King of the Andals" | GOTv2$title == "King of the Iron Islands" |
  GOTv2$title == "King of Winter" | GOTv2$title == "King-Beyond-the-Wall"] <- "King"

GOTv2$title[GOTv2$title == "Lady Marya" | GOTv2$title == "Lady of Bear Island" |
  GOTv2$title == "Lady of Darry" | GOTv2$title == "Lady of the Leaves" | GOTv2$title ==
  "Lady of the Vale" | GOTv2$title == "Lady of Torrhen's Square"] <- "Lady"

GOTv2$title[GOTv2$title == "LadyQueen" | GOTv2$title == "LadyQueenDowager Queen" |
  GOTv2$title == "PrincessQueen" | GOTv2$title == "QueenDowager Queen" | GOTv2$title ==
  "QueenBlack Bride"] <- "Queen"

GOTv2$title[GOTv2$title == "Prince of Dorne" | GOTv2$title == "Prince of Dragonstone" |
  GOTv2$title == "Prince of the Narrow Sea" | GOTv2$title == "Prince of Winterfell" |
  GOTv2$title == "Prince of WinterfellHeir to Winterfell"] <- "Prince"

GOTv2$title[grepl("Lord", GOTv2$title)] <- "Lord"

# Turning 'em back to factor as they should be #
GOTv2$title <- as.factor(GOTv2$title)

#### OG Dataset without imputing NA ####
write.csv(GOTv2, "GOTv2.csv")
