#!/bin/sh
#############################################################################
#
printf "Executing: %s\n" "$(basename $0)"
#
cwd=$(pwd)
#
NM_ROOT="/home/app/nextmove"
#
DATADIR="$cwd/data"
#
#############################################################################
# Chemical NER (drug intervention names), with default LeadMine dictionary
# and resolver. Must identify drugs by intervention ID, since may be multiple
# drugs per trial ID (NCT_ID).
###
java -jar /home/app/lib/unm_biocomp_nextmove-0.0.1-SNAPSHOT-jar-with-dependencies.jar \
	-i ${DATADIR}/aact_drugs.tsv \
	-textcol 3 -unquote -idcol 1 \
	-o ${DATADIR}/aact_drugs_leadmine.tsv \
	-v
#
###
# SMILES with wildcard ('*') maybe not supported by downstream apps (e.g. PubChem).
#