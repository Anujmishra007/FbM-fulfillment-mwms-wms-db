--rdt_629ExtVal02
exec rdt.rdtDropMsg 173451, 173452	

execute rdt.rdtAddMsg 173451, 10, '173451DiffLotLoc',   'us_english', 629
execute rdt.rdtAddMsg 173452, 10, '173452DiffLotLoc',   'us_english', 629
EXECUTE rdt.rdtAddMsg 173453, 10, '173453DiffLotID',   'us_english', 629
EXECUTE rdt.rdtAddMsg 173454, 10, '173454DiffLotID',   'us_english', 629
execute rdt.rdtAddMsg 173455, 10, '173455DiffLotID',   'us_english', 629
execute rdt.rdtAddMsg 173456, 10, '173456DiffLotID',   'us_english', 629



select * from rdt.rdtmsg (nolock) where message_id between 173451 and 173452



