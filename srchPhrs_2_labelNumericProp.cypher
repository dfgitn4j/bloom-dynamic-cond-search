// Search phrase
// Q2 - Find $label nodes with numeric property $property $condition $value

// Description
// Find nodes by label with a numeric property conditional clause

// Testing params for browser
:param label => 'Person';
:param property => 'born';
:param condition => '>=';
:param value => 1960;


// Cypher query
WITH "MATCH (n:" + $label + ") " +
  "WHERE n." + $property + 
  " " + $condition +
  " " + $value +
  " RETURN n" AS qryStr
CALL apoc.cypher.run(qryStr, {}) YIELD value AS nodes
RETURN nodes

// Parameter: $label; Data type: String; values: Cypher Query
CALL db.labels() YIELD label
WHERE NOT label IN [ '_Bloom_Perspective_', '_Bloom_Scene_' ]
RETURN label
// ORDER BY label DESC

// Parameter: $property data type: String; values: Cypher Query
CALL db.schema.nodeTypeProperties() YIELD nodeType, propertyName, propertyTypes
WHERE nodeType = ":`" + $label + "`"
  AND propertyTypes IN [['Long'], ['Double']]
RETURN DISTINCT propertyName

// Parameter: $condition data type: String; values: Cypher Query
UNWIND ["=", "<>", "<", ">", "<=", ">=", "IS NULL", "IS NOT NULL"] AS condition
RETURN condition

// Parameter $value; Data type: String; values: No suggestions
