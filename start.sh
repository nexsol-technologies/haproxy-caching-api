#!/bin/bash

# --------------
# PART A - download and extract the swiss postal code reference and import it in postgresql database
# --------------
# get the swiss postal code reference
curl -XGET https://data.geo.admin.ch/ch.swisstopo-vd.ortschaftenverzeichnis_plz/ortschaftenverzeichnis_plz/ortschaftenverzeichnis_plz_4326.csv.zip --output postal.zip

unzip postal.zip

#the csv file now in AMTOVZ_CSV_WGS84/AMTOVZ_CSV_WGS84.csv  

# --------------
# PART B - Launch the stack
# --------------
/usr/local/bin/docker-compose up -d
