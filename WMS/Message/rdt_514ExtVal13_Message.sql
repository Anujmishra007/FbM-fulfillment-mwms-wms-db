-- rdt_514ExtVal13
-- FCR-12938: UCC Move Putaway Zone Validation for AEOMX
EXECUTE rdt.rdtDropMsg 268051, 268100

EXECUTE rdt.rdtAddMsg 268051, 10, '268051^NoSKUPAZone',     'us_english', 514, 0, '268051: SKU Putaway zone not maintained'
EXECUTE rdt.rdtAddMsg 268052, 10, '268052^MIX SKU PA',      'us_english', 514, 0, '268052: MIX SKU Putaway zone mismatch'
EXECUTE rdt.rdtAddMsg 268053, 10, '268053^PAzoneMisMatch',  'us_english', 514, 0, '268053: Putaway zone mismatch'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 268051 AND 268100
