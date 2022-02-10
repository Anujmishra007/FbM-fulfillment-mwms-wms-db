-- rdt_ConReceive_Putaway
execute rdt.rdtDropMsg 55951, 56000

execute rdt.rdtAddMsg 55951, 10, '55951 ASNNotFinalize', 'us_english', 598
execute rdt.rdtAddMsg 55952, 10, '55952 Blank LOT     ', 'us_english', 598
execute rdt.rdtAddMsg 55953, 10, '55953 NoPutawayStock', 'us_english', 598
execute rdt.rdtAddMsg 55954, 10, '55954 NoSuitableLOC ', 'us_english', 598
execute rdt.rdtAddMsg 55955, 10, '55955 Need FinalLOC ', 'us_english', 598
execute rdt.rdtAddMsg 55956, 10, '55956 Diff LOC      ', 'us_english', 598
execute rdt.rdtAddMsg 55957, 10, '55957 Invalid LOC   ', 'us_english', 598
execute rdt.rdtAddMsg 55958, 10, '55958 Diff facility ', 'us_english', 598
