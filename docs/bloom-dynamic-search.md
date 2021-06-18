
# Dynamic and conditional Neo4j Bloom idiomatic user queries

Enabling BI tool like functionality in Neo4j Bloom —  “I want to easily search based on this and / or that logic” 

![](https://cdn-images-1.medium.com/max/2000/1*uaBIYm15pH_5RYbmC5pG0A.png)

Neo4j Bloom is a wonderful tool for navigating and visualizing a Neo4j graph without having to know the Cypher query language. This functionality is unique and a necessity for graph database end-users. Why? The variety and depth of connections between a graph’s nodes and relationships often cannot be determined ahead of time, and learning how to write a Cypher query, similar to learning SQL, can be limiting for some. Besides, it’s fun to be able to visually traverse the graph, similar to taking an unknown path through a forest. You never know what you might find. Take a quick look at the “Bloom Features: Near Natural Language Search” video if you’re not familiar with the Bloom search and graph navigation capabilities.

<center><iframe width="560" height="315" src="https://www.youtube.com/embed/9rL8O0lsuDc" frameborder="0" allowfullscreen></iframe></center>

Compare using Bloom to explore a graph with classic business intelligence tools such as Tableau, which are built on known structures and predetermined links instantiated at runtime between data tables (think joins). You’ll see that they solve two different user stories.
>  A Neo4j Graph can appear as a RDBMS and queried using SQL using the Neo4j BI Connector, but that’s a different topic. 
[**Using the BI Connector to Query Neo4j with SQL**
*Graphs and tables — SQL and Cypher!*medium.com](https://medium.com/neo4j/using-the-bi-connector-to-query-neo4j-with-sql-372eacb08fbc)

Idiomatic, near natural language search patterns in Bloom are great for many use cases, *except* when there’s a need to add declarative constructs to query patterns similar to BI tool functionality. The developers of Neo4j Bloom addressed this need by enabling custom Cypher queries to be run in Bloom via “Search Phrases”. Search phrases are parameterized Cypher queries that use a combination of text, parameters and Cypher to guide users through building a query in the Bloom search box, all without knowing Cypher! See the video below if you’re not familiar with Bloom search phrases. 

<iframe src="https://medium.com/media/4637aa97402be9afceb898e826ab54d6" frameborder=0></iframe>

### Example Time! Dynamic search based on if X and / or Y kinda stuff

***Things most don’t realize you can do with Bloom***

Many users want to be able to dynamically search the graph based on and / or logic. For example, “Find all :Person labeled nodes where the property born is between 1965 and 1992”. This declarative logic is something BI users are used to, but does not naturally integrate into the graph path traversal functionality of Bloom. On the other hand, visual unbounded traversing of a graph is not something BI users typically have.

Bloom search phrases can be used to address the need for conditional and declarative query constructs. The building block for this is one of my favorite Neo4j [apoc](https://neo4j.com/developer/neo4j-apoc/) procedures, apoc.cypher.run(). It’s a handy little function that will execute a Cypher query passed in as a string. Guess what? Bloom search phrases can dynamically build Cypher strings. This enables constructing search phrases that have an easy to use, no Cypher code needed to build and run complex Cypher queries. Below are some foundational examples to illustrate.

***👉 Run Cypher statement in Bloom 👈***

The most basic example of using apoc.cypher.run() in Bloom would be to create a search phrase to take a Cypher query string and execute it. Creating the search phrase would look like this: 

![](https://cdn-images-1.medium.com/max/2270/1*PzW7MqsP4WBLiTF9YWhpPg.png)

Users activate this search phrase by (assuming you’ve imported the blog’s Bloom perspective):

1. To run this query, start typing “Q1 -” in the search box and tab to complete the search phrase. 

1. Once you have Q1 — Cypher Input: showing the search box, type in the free-form Cypher query MATCH path=(:Person)-->().

1. Then press enter to execute the query which will show something similar to:

![](https://cdn-images-1.medium.com/max/2000/1*X5tA1XLVysrMd68y8Dyybg.png)

The Cypher query text entered in the search box as part of the search phrase is passed to the main query in the parameter $cypherText, which is then executed by apoc.cypher.run(). I’ve used this search phrase when I need a visualization that is too much for the Neo4j Browser to render. See the “Where’s My Neo4j Cypher Query Results” post for more details on when this might occur. 
[**Where’s My Neo4j Cypher Query Results? 😠 ⚡️ ⁉️**
*Why a Cypher query run in the Neo4j Browser may not return in a reasonable amount of time, what is happening, and what…*medium.com](https://medium.com/neo4j/wheres-my-neo4j-cypher-query-results-%EF%B8%8F-%EF%B8%8F-9c3b150e6e19)

Note the LIMIT clause in the query. It might be prudent to set a limit to the number of nodes returned by the submitted dynamic Cypher that matches the “Node query limit” setting in Bloom. Bloom will stop retrieving data when the node query limit setting is reached, so why query for more data than Bloom will allow to be returned and displayed?  Whether it makes sense to hard code a LIMIT clause is situational. Another option is to use the techniques described below use a parameter for the user to enter the maximum number of nodes that can be returned.

***👉 Search phrase that allows for conditionals on properties 👈***

Forming a query pattern in Bloom allows for flexible searching with exact matching values, but can be problematic other types operators. A Bloom search bar query currently cannot search for all :Person nodes with the born property > 1965, or properties on relationships. Not to worry! A generic search phrase can be used to guide a user through this functionality. Assuming you’ve setup the movies database: 

![Finding all :Person nodes with property born > 1965](https://cdn-images-1.medium.com/max/2000/1*tmIiloDMx7_MqpDl3wxiwg.gif)*Finding all :Person nodes with property born > 1965*

The above example was done with a search phrase that ***chains search phrase parameters***, where one parameter is used in other parameters logic. Below is the Bloom search phrase definition for the above shown in the Bloom search editing panel:

![Building a single condition test Bloom search phrase](https://cdn-images-1.medium.com/max/2000/1*rmcM2gqFh2jAnb58XZr6PA.png)*Building a single condition test Bloom search phrase*

This logic behind this search phrase is: 

1️⃣ ***Create Search Phrase.*** Enter search phrase text with the conditional parameters $label, $property, $condition and $value shown as ***a,b,c,d*** in the above image.

2️⃣ ***Add a user friendly description.***

3️⃣ ***Main Cypher Query***. The main Cypher query will be built concatenating the parameter values created in subsequent steps into a string to be run by apoc.cypher.run() The parameters are created in the search phrase defined in step 1️⃣:

    // Main Bloom Cypher query
    WITH "MATCH (n:" + $label + ") " +
      "WHERE n." + $property + 
      " " + $condition +
      " " + $value +
      " RETURN n" AS qryStr
    CALL apoc.cypher.run(qryStr, {}) YIELD value AS nodes
    RETURN nodes

4️⃣ ***Pick a Node Label***. Get the $label parameter value (‘a’ in the image). Present the users with all the labels in the database using the database metadata call db.labels() that returns what labels exist in the graph, except for the _Bloom_Perspective_ label because it does not hold any user data:

    // Parameter: $label; Data type: String; values: Cypher Query
    CALL db.labels() YIELD label
    WHERE label <> '_Bloom_Perspective_'
    RETURN label

5️⃣ ***Present Only Numeric Properties As a Query Option***. Get the $property parameter value (‘b’ in the image). Use the metadata database call db.schema.nodeTypeProperties() to return any property for the nodes that have the label defined in the $label parameter and are numeric values.

    // Parameter: $property data type: String; values: Cypher Query
    CALL db.schema.nodeTypeProperties() YIELD nodeType, propertyName, propertyTypes
    WHERE nodeType = ":`" + $label + "`"
      AND propertyTypes IN [['Long'], ['Double']]
    RETURN DISTINCT propertyName

This example restricts the search to numeric values to reduce the code shown in this blog. The “dynamic search…” example below with the code in the blog’s github repo that has logic to handle conditionals for different data types. For example, this search phrase parameter Cypher does not deal with string query conditionals such as STARTS WITH conditions. 

6️⃣ ***Present Conditional Operator.*** Pick a $condition parameter (‘c’ in the image). Only the valid conditionals for numerics are returned here. 

    // Parameter: $condition data type: String; values: Cypher Query
    UNWIND ["=", "<>", "<", ">", "<=", ">=", "IS NULL", "IS NOT NULL"] AS opX
    RETURN opX

IS NOT NULL and IS NULL can be used to test a properties existence, it could be switched to use [NOT] exists(<node.property>) with a different search phrase query pattern. 

7️⃣ ***Enter A Value To Query On.*** Free-format $value to search for (‘d’ in the image). No Cypher needed and the return value is String. The node properties to include in the main query is limited numeric values as picked up by the call to db.schema.nodeTypeProperties() in step 5️⃣. 

➡️  Last step is to save the query and run it using the Bloom search box.

Because each node can have a different set of properties, meaning that two different nodes can have a property with the same name but different data types. For example, it can be valid to have nodes with the property born = 1997 and another with born = ‘St. Mare’, with or without the same label(s).
> **Note:** There is a new scene filter capability in Bloom version 1.6 that will allow you to choose individual property values to filter the nodes in the scene. The difference with this search phrase is that the data is filtered in the query that retrieves data versus the scene filter that filters data has already been queried and is displayed by Bloom.

👉 ***Dynamic labels and search on multiple properties with AND/OR condition 👈***

Expanding on the above conditional logic example to include choosing a property, setting a conditional, then choosing AND / OR condition for a second property selection. This search phrase also presents the user with the proper conditional tests based on the data type of the property being tested. 

![Person born property IS NULL and name CONTAINS ‘J’](https://cdn-images-1.medium.com/max/2000/1*eeOHANEHTs4PfpY7iRaHzQ.gif)*Person born property IS NULL and name CONTAINS ‘J’*

A few things to note on how this search phrase was constructed when you look at the code in the file *srchPhrs_3_labelMultiProp.cypher* in the github repo:

* Spaces are a delimiter for the Bloom search box, which makes completing parameter terms with spaces, such as IS NOT NULL, tricky for the user to navigate. The approach used here for parameters with spaces is to have them replaced with an underbar (e.g. IS_NOT_NULL). Personally I think it’s easier to read the terms in the search box when clauses with spaces have underbars, such as IS_NOT_NULL and ENDS_WITH. The underbars for these phrases are replaced with spaces when the final string passed to apoc.cypher.run().

* Search phrase completion requires that each parameter have a value, and the conditional terms IS_NULL and IS_NOT_NULL do not have a target value. This is addressed by breaking the IS_ conditions into two parts. The first parameter can be IS_, which allows testing in the second parameter to present the user with NULL and NOT_NULL.

* The main query is a regular Cypher query, so string data types using as test values must be enclosed in quotes (the 'J' in the animation above). This is different from the typeahead functionality in the Bloom search box.

👉 ***Finding Multi-labeled Nodes 👈***

![](https://cdn-images-1.medium.com/max/2000/1*vrKvN345Tyg2sgys7AX4VQ.png)

A scenario that is occasionally asked for is to be able to search for nodes with multi-label combinations. To show this the movies database has been enhanced create labels on :Person and :Movie nodes as described in the github repo readme with the code in the *0_2_enhanceMovie.cypher* file:

    // New labels to make things interesting
      // A :Person labeled node can be: 
      //   Rich
      //   Famous
      //   Rich and famous
      //   Neither rich or famous
      //
      // A :Movie labeled node can be:
      //   Famous
      //   Or not

The query that drives this search phrase does not return a single label option because Bloom already does this. It also does not allow for invalid label combinations; a node with a :Person and :Movie label combination is not valid in the movie database and is excluded from the options presented to the user via the WHERE NOT clauses. 

    // Parameter $label; type String; output Cypher Query
    // Note: logic in the cypher query removes invalid label combinations for the enhanced movies graph

    CALL db.labels() YIELD label as label
    WHERE label <> '_Bloom_Perspective_'
    WITH  collect(label) as labels
    WITH labels, size(labels) as nbrLabels
    UNWIND apoc.coll.combinations(labels, 2, nbrLabels) AS labelCombos
    WITH labelCombos  // exclude invalid label combinations
    WHERE NOT ('Movie' IN labelCombos AND 'Person' IN labelCombos)
      AND NOT ('Movie' IN labelCombos AND 'Rich' IN labelCombos)
    WITH labelCombos
    WITH reduce(x = '', lab in labelCombos | x + ':' + lab + ' AND ' ) AS whereClause
    RETURN left(whereClause, size(whereClause) - 4) as whereClause

**👉** ***One last thing. *** ***Show the graph database schema ***👈

It’s always useful to see what types of labels, relationships and properties are in a graph which can easily be done with db.visualize.schema():

    CALL db.schema.visualization() YIELD nodes, relationships
    UNWIND nodes as node
    with node, relationships
    WHERE apoc.node.labels(node) <> ["_Bloom_Perspective_"]
    RETURN collect(node) AS nodes, relationships

![Result of :Schema search phrase](https://cdn-images-1.medium.com/max/2000/1*kLwUngjX-yx2KBqxVB9_kA.png)*Result of :Schema search phrase*

### What else might be done? 

* Allow search phrases that that work with data types that are unsupported in Bloom, such as datetime.

* Use aggregate functions to enable searching for minimum, maximum, averages, etc. of properties.

* Use predicate functions such as any() or all() for extended AND / OR query patterns.

Hopefully more examples could be added or suggested to the github repo for this post if anyone has other ideas. 

### Setup if you want to play along in your own Bloom environment

The Cypher statement files referenced in this blog can be found in the github repo:
[**dfgitn4j/bloom-dynamic-cond-search**
*This repository contains the supporting queries for the medium blog. The queries referenced in the blog are…*github.com](https://github.com/dfgitn4j/bloom-dynamic-cond-search)

The A few things need to be available and done to run the examples below in your own Bloom environment:

1. Have access to Neo4j Bloom, either through Neo4j Desktop or a server install.

1. Create the movies database running the :play movies gist in the Neo4j Browser, or running the Cypher in the file *0_1_creatMovieDB.cypher*.

1. Add new node label combinations by executing the Cypher in the file *0_2_enhanceMovie.cypher* if you want to run the multi-label combination search phrase example.

1. Import the perspective *Bloom conditional and dynamic queries.json* into Bloom by clicking on “Import Perspective” from Bloom’s Perspective Gallery.

### Tips and Techniques

A few tips about working with Bloom and the constructs presented in this blog:

1. The Bloom search box is very aggressive looking for relevant search phrases and graph patterns as users type. Having unique wording in a search phrase definition and description reduces the number of search phrases being presented to the user. 

1. Consider adding aLIMIT clause to dynamic queries generated using the technique described in this post that matches Bloom’s “Node query limit” parameter. 

1. Metadata commands such as the db.labels() used in search phrases will return Bloom Categories (labels in Neo4j graph database speak) that have not been included in the current Bloom Categories definition. Unwanted categories can be explicitly excluded in the search phrase Cypher. 

1. Case insensitivity does not work the same as with the Bloom case insensitive search option. Case insensitivity must be coded in the search phrase Cypher statements. 

1. Removing a query parameter while editing the search phrase definition and the corresponding parameter logic goes away. Save any code before you wish to keep.

1. There is no error checking. A runtime error will be shown if an incorrect Cypher statement is built.

Thank you for your time, and please add suggestions and code to the [github repo](https://github.com/dfgitn4j/bloom-dynamic-cond-search) for this blog if you have other useful search phrase patterns. I will be adding some in the future that are bouncing around in my “when I have spare time and have functional consciousness” spot in my b̶r̶i̶a̶n brain.
