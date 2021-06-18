// Create function to return label property data type 
CALL apoc.custom.asFunction( 'propertyType',
 'WITH \'MATCH (n:\' + $label + \') \' +
    \'WHERE exists(n.\' + $property + \') \' +
    \'WITH n.\' + $property + 
    \' AS prop LIMIT 1 RETURN apoc.meta.cypher.type(prop) \' AS qryStr
  CALL apoc.cypher.run(qryStr, {}) YIELD value AS propType
  RETURN propType',
  'RETURN propType',
  [['label', 'STRING', ''], ['property', 'STRING', '']], TRUE, 'RETURN label.property cypher data type')

// query to use if not wanting to use function
// WITH "MATCH (n:" + $label + ") WITH apoc.meta.cypher.type(n." + $property + ") AS propType LIMIT 1 RETURN propType" AS qryStrProp
// CALL apoc.cypher.run(qryStrProp, {}) YIELD value AS retMap
// WITH 
//  CASE retMap.propType
//   WHEN "STRING" THEN ["STARTS WITH", "CONTAINS", "ENDS WITH"]
//   ELSE []
// END AS strOpts
// UNWIND strOpts + ["=", "<>", "<", ">", "<=", ">=", "IS NULL", "IS NOT NULL"] AS operator1
// RETURN operator1


// Create prodedure that returns the operator comparison strings as rows based on if the 
// label.property data type is a string or not
// Best for properties that have homogeneous data types
CALL apoc.custom.asProcedure( 'getCompareOps',
  'WITH \'MATCH (n:\' + $label + \') WITH apoc.meta.cypher.type(n.\' +
   $property + \') AS propType LIMIT 1 RETURN propType\' AS qryStrProp
   CALL apoc.cypher.run(qryStrProp, {}) YIELD value AS retMap
   WITH 
   CASE retMap.propType
     WHEN "STRING" THEN ["STARTS WITH", "CONTAINS", "ENDS WITH"]
     ELSE []
   END AS strOpts
   UNWIND strOpts + ["=", "<>", "<", ">", "<=", ">=", "IS NULL", "IS NOT NULL"] AS operator
   RETURN operator',
   'read',
   [['operator', 'STRING']], [['label', 'STRING', ''],['property', 'STRING', '']], 'Return appropriate WHERE clause operators for label.property cypher data type')

// query to us if not wanting to use procedure
// parameters for testing
// data types
// :param property => 'name'
// ;
// :param label => 'Person'
// WITH 'MATCH (n:' + $label + ') WITH apoc.meta.cypher.type(n.' +
//    $property + ') AS propType LIMIT 1 RETURN propType' AS qryStrProp
//    CALL apoc.cypher.run(qryStrProp, {}) YIELD value AS retMap
//    WITH 
//    CASE retMap.propType
//      WHEN "STRING" THEN ["STARTS WITH", "CONTAINS", "ENDS WITH"]
//      ELSE []
//    END AS strOpts
//    UNWIND strOpts + ["=", "<>", "<", ">", "<=", ">=", "IS NULL", "IS NOT NULL"] AS operator
//    RETURN operator// 