-- rdt_1812ExtVal06
EXEC rdt.rdtDropMsg 260301, 260350

EXECUTE rdt.rdtAddMsg 260301, 10, '260301 ToteInUse',             'us_english', 1812, 0, '260301 Tote in use'
EXECUTE rdt.rdtAddMsg 260302, 10, '260302 DropIDInUse',           'us_english', 1812, 0, '260302 DropID in use'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 260301 AND 260350