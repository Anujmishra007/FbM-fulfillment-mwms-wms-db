
--rdt_888ExtVal01
--248851 - 248900

execute rdt.rdtdropmsg 248851, 248900			

execute rdt.rdtAddMsg 248851, 10, '248851^RcptGrpNotAllow',     'us_english', 888, 0, '248851 Receipt Group not allowed'
execute rdt.rdtAddMsg 248852, 10, '248852^LOCRequired',         'us_english', 888, 0, '248852 Loc is required'
execute rdt.rdtAddMsg 248853, 10, '248853^IDRequired',          'us_english', 888, 0, '248853 ID is required'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 248851 AND 248900