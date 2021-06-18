// Search phrase
// Q4 - Nodes with label combinations $labelCombos

// Description
// Find nodes with multiple label combinations

// Testing params for browser
:param label => 'Person';
:param property => 'born';
:param condition => '>=';
:param val1 => 1960;


// Cypher query
WITH "MATCH (is) WHERE " + replace($labelCombos, ':', 'is:') + " RETURN is" AS qryStr
CALL apoc.cypher.run(qryStr, {}) YIELD value AS nodes
RETURN nodes

// Parameter: $label; Data type: String; values: Cypher Query
CALL db.labels() YIELD label
WHERE label <> '_Bloom_Perspective_'
RETURN label


// Parameter: $labelCombose data type: String; values: Cypher Query
// WHERE clause breaks removes invalid label combinations for this graph
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

