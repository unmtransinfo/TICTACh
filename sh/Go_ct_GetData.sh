#!/bin/bash
#############################################################################
### CTTI = Clinical Trials Transformation Initiative
### AACT = Aggregate Analysis of ClinicalTrials.gov
### See https://aact.ctti-clinicaltrials.org/.
### According to website (July 2018), data is refreshed monthly.
#############################################################################
### Identify drugs by intervention ID, since may be multiple
### drugs per trial (NCT_ID).
#############################################################################
### Purpose:
###   * Associate drugs with diseases/phenotypes.
###   * Associate protein targets with diseases/phenotypes.
###   * Associate drugs with protein targets.
#############################################################################
### Tables of interest:
###	[x] studies
###	[x] keywords
###	[x] brief_summaries
###	[x] detailed_descriptions
###	[x] conditions
###	[x] browse_conditions		(NCT-MeSH links)
###	[x] interventions
###	[ ] browse_interventions	(NCT-MeSH links)
###	[ ] intervention_other_names	(synonyms)
###	[ ] study_references		(including type results_reference)
#############################################################################
#
set -x
#
DBHOST="aact-db.ctti-clinicaltrials.org"
DBNAME="aact"
#
cwd=$(pwd)
DATADIR="${cwd}/data"
#
ARGS="-h $DBHOST -d $DBNAME"
###
psql $ARGS -c "COPY (SELECT nct_id,study_type,source,phase,overall_status,start_date,completion_date,enrollment,official_title FROM studies) TO STDOUT WITH (FORMAT CSV,HEADER,DELIMITER E'\t')" \
	>$DATADIR/aact_studies.tsv
###
###
#Drugs:
psql $ARGS -c "COPY (SELECT id, nct_id, name FROM interventions WHERE intervention_type ='Drug') TO STDOUT WITH (FORMAT CSV,HEADER,DELIMITER E'\t')" \
	>$DATADIR/aact_drugs.tsv
###
#Keywords:
psql $ARGS -c "COPY (SELECT id, nct_id, name FROM keywords) TO STDOUT WITH (FORMAT CSV,HEADER,DELIMITER E'\t')" \
	>$DATADIR/aact_keywords.tsv
#
###
#Conditions:
psql $ARGS -c "COPY (SELECT id, nct_id, name FROM conditions) TO STDOUT WITH (FORMAT CSV,HEADER,DELIMITER E'\t')" \
	>$DATADIR/aact_conditions.tsv
#
###
#Conditions_MeSH:
psql $ARGS -c "COPY (SELECT id, nct_id, mesh_term FROM browse_conditions) TO STDOUT WITH (FORMAT CSV,HEADER,DELIMITER E'\t')" \
	>$DATADIR/aact_conditions_mesh.tsv
#
###
#Interventions_MeSH:
psql $ARGS -c "COPY (SELECT id, nct_id, mesh_term FROM browse_interventions) TO STDOUT WITH (FORMAT CSV,HEADER,DELIMITER E'\t')" \
	>$DATADIR/aact_interventions_mesh.tsv
#
###
#Interventions Other Names:
psql $ARGS -c "COPY (SELECT id, nct_id, intervention_id, name FROM intervention_other_names) TO STDOUT WITH (FORMAT CSV,HEADER,DELIMITER E'\t')" \
	>$DATADIR/aact_interventions_othernames.tsv
#
###
#Study references:
psql $ARGS -c "COPY (SELECT id, nct_id, reference_type, pmid, citation FROM study_references) TO STDOUT WITH (FORMAT CSV,HEADER,DELIMITER E'\t')" \
	>$DATADIR/aact_study_refs.tsv
#
###
#Special handling required to clean newlines and tabs.
###
ARGS="-Atq -h $DBHOST -d $DBNAME"
#Brief Summaries:
SUMMARYFILE=$DATADIR/aact_summaries.tsv
printf "id\tnct_id\tdescription\n" >$SUMMARYFILE
psql -F $'\t' $ARGS -f sql/summary_list.sql >>$SUMMARYFILE
#
###
#Descriptions:
DESCRIPTIONFILE=$DATADIR/aact_descriptions.tsv
printf "id\tnct_id\tdescription\n" >$DESCRIPTIONFILE
psql -F $'\t' $ARGS -f sql/description_list.sql >>$DESCRIPTIONFILE
#