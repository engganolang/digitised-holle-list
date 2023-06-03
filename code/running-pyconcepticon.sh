# running pyconcepticon on terminal
## assuming I already created virtual environment "myenv" in `cldf_project` direactory
## already installed the relevant Python packages
## and already downloaded the Concepticon database in the `concepticon/concepticon-data` directory

# go the the relevant directory
cd /Users/Primahadi/Documents/cldf_project

# activate the virtual environment
source myenv/bin/activate

# go the concepticon directory
cd concepticon/concepticon-data

# run the concept mapping
concepticon map_concepts /Users/Primahadi/Documents/enggano-AHRC/holle-list-2023-05-23/data/Stokhof-1980-1486.tsv > test.tsv

