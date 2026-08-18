-- rdt_1812ExtVal07
EXEC rdt.rdtDropMsg 276651, 276700

EXECUTE rdt.rdtAddMsg 276651, 10, '276651 LocCat Diff',     'us_english', 1812, 0, '276651: location category mismatch'
EXECUTE rdt.rdtAddMsg 276652, 10, '276652 NoSuggToLoc',     'us_english', 1812, 0, '276652: Suggested ToLoc not found in task'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 276651 AND 276700
