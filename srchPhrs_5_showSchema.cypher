// Search phrase
// :Schema

// visualize schema
CALL db.schema.visualization()

// -------
// Alternative ways to show the Neo4j Schema
// -------

// Exclude the _Bloom_Perspective_
CALL db.schema.visualization() YIELD nodes, relationships
UNWIND nodes as node
with node, relationships
WHERE apoc.node.labels(node) <> ["_Bloom_Perspective_"]
RETURN collect(node) AS nodes, relationships


// -------
// The following queries are courtesy of https://medium.com/@dave_voutila
// -------

// more control over what comes back, e.g.
// ["_Bloom_Perspective_"] could be a list of things not to include ["_Bloom_Perspective_", "BAD_RELATIONSHIP"]
CALL db.schema.visualization() YIELD nodes, relationships
RETURN
[n IN nodes WHERE any(lbl IN apoc.node.labels(n)
  WHERE NOT lbl IN ["_Bloom_Perspective_"])] AS nodes, relationships

// Same concept as above, except return only ["Movie", "Famous", "Person"], and 
// any relationship *except* ["REVIEWED"]
CALL db.schema.visualization() YIELD nodes, relationships
RETURN
[n IN nodes WHERE none(lbl IN apoc.node.labels(n)
  WHERE NOT lbl IN ["Movie", "Famous", "Person"])] AS nodes,
[r IN relationships WHERE NOT apoc.rel.type(r) IN ["REVIEWED"]] AS relationships