-- 235851 - 235900

execute rdt.rdtDropMsg 240401, 240450

execute rdt.rdtAddMsg 240401, 10, '240401OptRequired',      'us_english', 839, 0, '240401: Option is required'
execute rdt.rdtAddMsg 240402, 10, '240402InvOption',        'us_english', 839, 0, '240402: Invalid option'
execute rdt.rdtAddMsg 240403, 10, '240403RealloFail',       'us_english', 839, 0, '240403: Reallocation failed. Perform manual reallocation'
execute rdt.rdtAddMsg 240404, 10, '240404PutawayZoneEmpty',    'us_english', 839, 0, '240404: PutawayZone cannot be empty'
execute rdt.rdtAddMsg 240405, 10, '240405Moveflag cannot set ',    'us_english', 839, 0, '240405: Movement flag cannot be set in reallocation'


SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 240401 AND 240450
