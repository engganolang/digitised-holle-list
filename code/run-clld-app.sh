# Testing to serve the Holle's New Basic List with clld app
## my personal note
## assumption:
### - glottolog data has been downloaded inside the cldf_project directory
### - Python virtual environment has been created in the cldf_project directory
### - clld package has been installed in the myenv
### - cldf Holle List (https://github.com/engganolang/digitised-holle-list) has been ready

cd /Users/Primahadi/Documents/cldf_project

# activate the virtual environment
source myenv/bin/activate

# remove the already existing hollelist directory to re-run a new app
rm -r hollelist

# create the app infrastructure, with Wordlist module
clld create hollelist cldf_module=Wordlist

# go to the app directory
cd hollelist  

# install requirement
pip install -r requirements.txt

# create the database for the Holle List CLDF
## stored in my computer: /Users/Primahadi/Documents/enggano-AHRC/holle-list-2023-05-23/cldf/cldf-metadata.json 
clld initdb --glottolog ../glottolog-glottolog-d9da5e2/ --cldf /Users/Primahadi/Documents/enggano-AHRC/holle-list-2023-05-23/cldf/cldf-metadata.json development.ini

# check the app
pserve development.ini