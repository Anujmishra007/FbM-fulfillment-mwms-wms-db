-- rdt_839ExtScn07
-- FCR-10041
-- 257901 - 257950


execute rdt.rdtDropMsg 257901, 257950

execute rdt.rdtAddMsg 257901, 10, '257901OptRequired',      'us_english', 839, 0, '257901: Option is required'
execute rdt.rdtAddMsg 257902, 10, '257902InvOption',        'us_english', 839, 0, '257902: Invalid option'
execute rdt.rdtAddMsg 257903, 10, '257903RealloFail',       'us_english', 839, 0, '257903: Reallocation failed. Perform manual reallocation'
execute rdt.rdtAddMsg 257904, 10, '257904PickZoneEmpty',    'us_english', 839, 0, '257904: PickZone cannot be empty'


SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 257901 AND 257950
