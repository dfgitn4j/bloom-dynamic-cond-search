// main query

// Test data
//

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

MATCH (r:Rich) REMOVE r:Rich
;
MATCH (f:Person:Famous) REMOVE f:Famous
;

MATCH (n:Person) WITH collect(id(n)) AS nodeIds
WITH size(nodeIds) AS nbrNodeIds, nodeIds
WITH apoc.coll.randomItems(nodeIds, toInteger(nbrNodeIds * .7)) as famous
UNWIND famous AS idf
MATCH (f:Person) WHERE id(f) = idf
  SET f:Famous  // Person is famous
;
MATCH (f:Famous) 
WHERE id(f) % 10 <= 7
  SET f:Rich   // Person is rich and famous
;
MATCH (p:Person)
WHERE NOT p:Famous
  AND id(p) % 10 <= 2 // Person is just rich
SET p:Rich
;
// Make some movies famous
MATCH (m:Movie) 
WHERE id(m) % 10 <= 6
  SET m:Famous
;

// ----------
// View results queries
// ----------
// results of rich and famous
MATCH (p:Person:Rich:Famous) RETURN 'Rich And Famous' AS label, count(p)
UNION
MATCH (p:Person:Famous) WHERE NOT p:Rich RETURN 'Famous only' AS label, count(p)
UNION
MATCH (p:Person:Rich) WHERE NOT p:Famous RETURN 'Rich only' AS label, count(p)
UNION
MATCH (p:Person) WHERE NOT (p:Rich OR p:Famous) RETURN 'No consequence' AS label, count(p)
;


// test query for multi-label nodes with rules to avoid  
// invalid label combinations Movie/Person and Movie/Rich
CALL db.labels() YIELD label
WHERE label <> "_Bloom_Perspective_"
WITH  collect(label) as labels
WITH labels, size(labels) as nbrLabels
UNWIND apoc.coll.combinations(labels, 2, nbrLabels) AS labelCombinations
WITH labelCombinations  // exclude invalid label combinations
WHERE NOT ('Movie' IN labelCombinations AND 'Person' IN labelCombinations)
  AND NOT ('Movie' IN labelCombinations AND 'Rich' IN labelCombinations)
RETURN labelCombinations


// Multi-type node
// CREATE (n:Person)
//    SET n.isString = 'A name',
//        n.isInt = 100,
//        n.isFloat = 12.34,
//        n.isDatetime = datetime('2020-01-01'),
//        n.isSpatial = point({x: 0, y: 4, z: 1})
// ;
