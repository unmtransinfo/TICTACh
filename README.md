# `TICTAC` - Target illumination clinical trials analytics with cheminformatics

Mining ClinicalTrials.gov via AACT-CTTI-db for target hypotheses, with strong
cheminformatics and medical terms text mining, powered by NextMove LeadMine
and JensenLab Tagger.

### Dependencies

* [AACT-CTTI-db](https://aact.ctti-clinicaltrials.org/)
* [NextMove LeadMine](http://nextmovesoftware.com)
* [JensenLab Tagger](https://github.com/larsjuhljensen/tagger/)
* [BioClients](https://github.com/jeremyjyang/BioClients)

### About AACT:
* [AACT-CTTI](https://aact.ctti-clinicaltrials.org/) database from Duke.
  * CTTI = Clinical Trials Transformation Initiative
  * AACT = Aggregate Analysis of ClinicalTrials.gov
* According to website (July 2018), data is refreshed monthly.
* Identify drugs by intervention ID, since may be multiple drugs per trial \(NCT\_ID\).

### References:
* <http://clinicaltrials.gov>
* <https://aact.ctti-clinicaltrials.org/>
* [AACT Data Dictionary](https://aact.ctti-clinicaltrials.org/data_dictionary), which references <https://prsinfo.clinicaltrials.gov/definitions.html> and <https://prsinfo.clinicaltrials.gov/results_definitions.html>.
* [The Database for Aggregate Analysis of ClinicalTrials.gov (AACT) and Subsequent Regrouping by Clinical Specialty](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0033677), Tasneem et al., March 16, * 2012https://doi.org/10.1371/journal.pone.0033677.
* [How to avoid common problems when using ClinicalTrials.gov in research: 10 issues to consider](https://www.bmj.com/content/361/bmj.k1452), Tse et al., BMJ 2018; 361 doi: https://doi.org/10.1136/bmj.k1452 (Published 25 May 2018.
* See also: <https://www.ctti-clinicaltrials.org/briefing-room/publications>

### Text mining, aka Named Entity Recognition (NER)
* Chemical NER by [NextMove LeadMine](http://nextmovesoftware.com).
* Disease NER by [JensenLab](https://jensenlab.org/) [Tagger](https://github.com/larsjuhljensen/tagger/).

### Purpose:
* Associate drugs with diseases/phenotypes.
* Associate drugs with protein targets.
* Associate protein targets with diseases/phenotypes (via drugs).
* Predict and score disease-target associations.

___Drugs___ may be experimental candidates.

### AACT tables of interest:
| *Table* | *Notes* |
| ---: | :--- |
| **studies** | titles |
| **keywords** | Reported; multiple vocabularies. |
| **brief\_summaries** | (max 5000 chars) |
| **detailed\_descriptions** | (max 32000 chars) |
| **conditions** | diseases/phenotypes |
| **browse\_conditions** | MeSH links |
| **interventions** | Our focus is drugs only among several types. |
| **browse\_interventions** | MeSH links |
| **intervention\_other\_names** | synonyms |
| **study\_references** | PubMed links |
| **reported\_events** | including adverse events |

### Overall workflow:

See top level script `Go_ctgov_Workflow.sh`.

1. Data:
  1. `Go_ctgov_GetData.sh` - Fetch data from AACT db.
1. LeadMine:
  1. `Go_ctgov_NER_leadmine_chem.sh` - LeadMine NER, CT descriptions.
  1. `Go_pubmed_NER_leadmine_chem.sh` - LeadMine NER, referenced PMIDs.
1. Tagger:
  1. `Go_ctgov_NER_tagger_disease.sh` - Tagger NER, CT descriptions.
1. Cross-references:
  1. `Go_xref_drugs.sh` - PubChem and ChEMBL IDs via APIs.
1. Results, analysis:
  1. `tictac.Rmd` - Results described and analyzed.

Dependencies:
* [PubChem REST API](http://pubchem.ncbi.nlm.nih.gov/rest/pug/)
* [ChEMBL REST API](https://www.ebi.ac.uk/chembl/ws)
* [ChEMBL webresource client](https://github.com/chembl/chembl_webresource_client) \(Python client library\).
* [JensenLab](https://jensenlab.org/) [Tagger](https://bitbucket.org/larsjuhljensen/tagger/).
* [NextMove LeadMine](http://nextmovesoftware.com).
* [nextmove-tools](https://github.com/unmtransinfo/nextmove-tools)

### Association semantics:
* **keywords**, **conditions**, **studies** and **summaries**: reported terms and free text which may be text mined for intended associations.
* **descriptions**:  may be text mined for both the intended and other conditions, symptoms and phenotypic traits, which may be non-obvious from the study design.
* **study\_references**: via PubMed, text mining of titles, abstracts can associate disease/phenotypes, protein targets, chemical entities and more.  The "results\_reference" type may include findings not anticipated in the design/protocol.
* **interventions** include drug names which can be recognized and mapped to standard IDs, a task for which NextMove LeadMine is particularly suited.
* LeadMine chemical NER also resolves entities to structures via SMILES, enabling downstream cheminformatics such as aggregation by chemical substructure and similarity.
