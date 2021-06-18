// Search phrase
// Q3 - Nodes labeled $label where $property1 $operator1 $val1 $andOr $property2 $operator2 $val2

// Description
// Nodes labeled [label] where [property] [condition] [value] [and / or] [property] [condition] [value]

// Testing params for browser
:param label => 'Person';
:param property1 => 'born';
:param operator1 => 'IS_NOT_NULL';
:param val1 => '';
:param andOr => 'AND';
:param property2 => 'born';
:param operator2 => '>=';
:param val2 => '1960';

// Cypher query
// IS [NOT] NULL has no follow-on testing values
WITH CASE WHEN $operator1 IN ['IS_NULL', 'IS_NOT_NULL'] THEN $operator1 ELSE $operator1 + ' ' + $val1 END AS cond1,
     CASE WHEN $operator2 IN ['IS_NULL', 'IS_NOT_NULL'] THEN $operator2 ELSE $operator2 + ' ' + $val2 END AS cond2
WITH "MATCH (n:" + $label + ")" +
  " " + "WHERE n." + $property1 + 
  " " + replace(cond1, '_', ' ') + 
  " " + $andOr +
  " " + " n." + $property2 +
  " " + replace(cond2, '_', ' ') + 
  " RETURN n" AS qryStr
CALL apoc.cypher.run(qryStr, {}) YIELD value AS nodes
RETURN nodes

// Parameter: $label; Data type: String; values: Cypher Query
CALL db.labels() YIELD label
WHERE label <>  '_Bloom_Perspective_'
RETURN label


// Parameter: $property1 data type: String; values: Cypher Query
// Using apoc.meta.nodeTypeProperties to easily filter by label and add sample size as an example 
CALL apoc.meta.nodeTypeProperties({labels : [$label], sample : 2000}) YIELD propertyName
RETURN DISTINCT propertyName AS property1

// Parameter: $operator1 data type: String; values: Cypher Query
WITH 'MATCH (n:' + $label + ') WITH apoc.meta.cypher.type(n.' +
   $property1 + ') AS propType LIMIT 1 RETURN propType' AS qryStrProp
   CALL apoc.cypher.run(qryStrProp, {}) YIELD value AS retMap
   WITH 
   CASE retMap.propType
     WHEN "STRING" THEN ["STARTS_WITH", "CONTAINS", "ENDS_WITH"]
     ELSE []
   END AS strOpts
   UNWIND strOpts + ["=", "<>", "<", ">", "<=", ">=", "IS_"] AS operator
RETURN operator AS operator1

// Parameter: $val1 data type: String; values: Cypher Query
// Add completion if $operator1 value is 'IS_', else take user input
WITH CASE WHEN $operator1 = 'IS_'  THEN ['NULL', 'NOT_NULL'] ELSE [''] END as v
UNWIND v AS val1
RETURN val1

// Parameter: $andOr data type: String; values: Cypher Query
UNWIND ["AND", "OR"] as andOr
RETURN andOr

// Parameter: $property2 data type: String; values: Cypher Query
// Using apoc.meta.nodeTypeProperties to easily filter by label and add sample size as an example 
CALL apoc.meta.nodeTypeProperties({labels : [$label], sample : 2000}) YIELD propertyName
RETURN DISTINCT propertyName AS property2

// Parameter: $operator2 data type: String; values: Cypher Query
WITH 'MATCH (n:' + $label + ') WITH apoc.meta.cypher.type(n.' +
   $property2 + ') AS propType LIMIT 1 RETURN propType' AS qryStrProp
   CALL apoc.cypher.run(qryStrProp, {}) YIELD value AS retMap
   WITH 
   CASE retMap.propType
     WHEN "STRING" THEN ["STARTS_WITH", "CONTAINS", "ENDS_WITH"]
     ELSE []
   END AS strOpts
   UNWIND strOpts + ["=", "<>", "<", ">", "<=", ">=", "IS_"] AS operator
RETURN operator AS operator2

// Parameter: $val2 data type: String; values: Cypher Query
// Add completion if $operator1 value is 'IS', else take user input
WITH CASE WHEN $operator2 = 'IS_'  THEN ['NULL', 'NOT_NULL'] ELSE [''] END as v
UNWIND v AS val2
RETURN val2

