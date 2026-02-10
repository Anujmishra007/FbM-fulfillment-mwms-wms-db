-- 251951, 252000

execute rdt.rdtDropMsg 251951, 240450

execute rdt.rdtAddMsg 251951, 10, '251951OptRequired',      'us_english', 830, 0, '251951: Option is required'
execute rdt.rdtAddMsg 251952, 10, '251952InvOption',        'us_english', 830, 0, '251952: Invalid option'
execute rdt.rdtAddMsg 251953, 10, '251953RealloFail',       'us_english', 830, 0, '251953: Reallocation failed. Perform manual reallocation'
execute rdt.rdtAddMsg 251954, 10, '251954PutawayZoneEmpty',    'us_english', 830, 0, '251954: PutawayZone cannot be empty'
execute rdt.rdtAddMsg 251955, 10, '251955ToLOcNotFound',    'us_english', 830, 0, '251955: Need to set up default TOLOC'
execute rdt.rdtAddMsg 251956, 10, '251956DefaultToNotFound',    'us_english', 830, 0, '251956: DefaultToNotFound'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 251951 AND 252000
