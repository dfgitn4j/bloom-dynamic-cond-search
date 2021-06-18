// Search phrase
// Q1 - Cypher Input: $cypherText

// Description
// Input Cypher (Return a path / no syntax checking)
// ==> Suggestion: Put in a LIMIT clause based on your experience to avoid 
//                 queries returning more data that is worth visualizing, or 
//                 is greater than the "Node query limit" setting in Bloom.
//                 Another option is to add it as a parameter. 

// Testing params for browser
:param $cypherText => 'MATCH path=(n:Person)-->() RETURN path';

// Cypher query
CALL apoc.cypher.run($cypherText + ' LIMIT 3000', {}) YIELD value as results
RETURN results
// Parameter $cypherText; Data type: String; values: No suggestions

