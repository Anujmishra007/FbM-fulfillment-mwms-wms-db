--rdt_1841ExtScn01
--FCR-9027
execute rdt.rdtdropmsg 252351, 252400

execute rdt.rdtAddMsg 252351, 10, '252351 CartonIDNeeded',     'us_english', 1841, 0, '252351 Carton ID Needed'
execute rdt.rdtAddMsg 252352, 10, '252352 CartonIDExists',     'us_english', 1841, 0, '252352 Carton ID Already Exists'
execute rdt.rdtAddMsg 252353, 10, '252353 UpdSortDataFail',    'us_english', 1841, 0, '252353 Update Sort Data Failed'
execute rdt.rdtAddMsg 252354, 10, '252354 CartonIDExists',     'us_english', 1841, 0, '252354 Carton ID Already Scanned'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 252351 AND 252400