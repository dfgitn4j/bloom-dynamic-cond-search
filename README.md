# bloom-dynamic-search-phrase

![](images/stewieBetterBloom.jpg)

### Love working with Neo4j Bloom, but miss being able to to AND / OR conditional searches that you're used to with classic BI tools? _*Hopefully*_ this will help.  

This repository contains the supporting queries for the [medium blog](https://medium.com/p/bdf0a2984837/).  

The Cypher queries referenced are data creation queries:

| File Name                          | Description                                                                     |  
| ---------------------------------- | ------------------------------------------------------------------------------- |  
| 0_1_creatMovieDB.cypher            | Create movies db, from :play movies gist                                        |
| 0_2_enhanceMovie.cypher            | Add `:Rich` and `:Famous` labels for multi-label search phrase                  |

The files beginning with "srchPhrs_" contain the text needed to create a Bloom search phrase. The files are broken into sections to match the input needed to build the Bloom search phrase.  The `:param` statements in these files provide parameter testing values for running the main Cypher query standalone.  The Bloom search phrase definition files are:

| File Name                          | Description                                                                     | 
| ---------------------------------- | ------------------------------------------------------------------------------- |
| srchPhrs_1_runCypherText.cypher    | Search Phrase to run cypher query input                                         |
| srchPhrs_2_labelNumericProp.cypher | Search Phrase to pick a label and create conditional on a numeric property      |
| srchPhrs_3_labelMultiProp.cypher   | Search Phrase to pick a label with AND / OR conditionals on multiple properites |
| srchPhrs_4_multiLabelCombo.cypher  | Search Phrase to retrieve nodes with valid multiple label combinations          |
| srchPhrs_5_showSchema.cypher       | Search Phrase to show graph schema (pick one)                                   |


   *** 

## Setup


### Enhancing the movies database

run the Cypher in "_0_2_enhanceMovie.cypher_" if you want to run the multi-label search phrase, then after you've created the movies database (you do).

### Import Bloom perspective that includes the above search phrases into Bloom

1. Make the movies database referenced above the current running database.

1. Start Neo4j Bloom, either from Neo4j Desktop or the url for your server install.

1. Import the perspective "_Bloom conditional and dynamic queries.json_" into Bloom by clicking on "Import Perspective" from Bloom's Perspective Gallery.

