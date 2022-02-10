-- rdt_MoveSKUSuggLoc03
execute rdt.rdtDropMsg 84001, 84050

execute rdt.rdtAddMsg 84001, 10, '84001^NoSuitableLOC ',   'us_english', 513
execute rdt.rdtAddMsg 84002, 10, '84002^NoSuggestedLOC',   'us_english', 513
