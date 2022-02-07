-- rdt_922ExtVal11
execute rdt.rdtdropmsg 161951 , 162000	

execute rdt.rdtAddMsg 161951, 10, '161951Diff GI date  ', 'us_english', 922
execute rdt.rdtAddMsg 161952, 10, '161952LebelNotInLoad', 'us_english', 922
execute rdt.rdtAddMsg 161953, 10, '161953Pack NotFinish', 'us_english', 922
execute rdt.rdtAddMsg 161954, 10, '161954Need LoadKey  ', 'us_english', 922
execute rdt.rdtAddMsg 161955, 10, '161955Need SITE     ', 'us_english', 922
execute rdt.rdtAddMsg 161956, 10, '161956Invalid site  ', 'us_english', 922
execute rdt.rdtAddMsg 161957, 10, '161957Site NotInLoad', 'us_english', 922


SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 161951 AND 162000	