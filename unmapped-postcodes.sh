#!/bin/bash

cd ~/fhrs-osm-unmapped-postcodes

# get Robert's postcode data and remove intermediate files
wget -q http://robert.mathmos.net/osm/postcodes/osm-num.zip || exit 1
unzip osm-num.zip || exit 1
rm osm-num.zip
echo "Postcode	Mapped" | cat - osm-num.dat > postcodes.tsv || exit 1
rm osm-num.dat

# get FHRS data
psql -d gregrs_fhrs -c 'COPY (SELECT "FHRSID", "BusinessName", "PostCode" FROM fhrs_establishments) TO STDOUT CSV HEADER' > fhrs.csv || exit 1

# create empty output directory
if [ -d output ]; then
	rm -r output
fi
mkdir output || exit 1

# process data using R
Rscript unmapped-postcodes.R || exit 1

# copy output files to public_html
cp output/*.csv ../public_html/fhrs-unmapped-postcodes/
