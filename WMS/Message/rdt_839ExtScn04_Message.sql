-- rdt_839ExtScn04
-- FCR-2705
-- 235851 - 235900

execute rdt.rdtDropMsg 235851, 235900

execute rdt.rdtAddMsg 235851, 10, '235851OptRequired',      'us_english', 839, 0, '235851: Option is required'
execute rdt.rdtAddMsg 235852, 10, '235852InvOption',        'us_english', 839, 0, '235852: Invalid option'
execute rdt.rdtAddMsg 235853, 10, '235853RealloFail',       'us_english', 839, 0, '235853: Reallocation failed. Perform manual reallocation'
execute rdt.rdtAddMsg 235854, 10, '235854PickZoneEmpty',    'us_english', 839, 0, '235854: PickZone cannot be empty'


SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 235851 AND 235900
