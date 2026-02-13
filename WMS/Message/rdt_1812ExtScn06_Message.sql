-- rdt_1812ExtScn06
execute rdt.rdtDropMsg 245401 , 245450

execute rdt.rdtAddMsg 245401, 10, '245401 InventoryHoldFailed',      'us_english', 1812
execute rdt.rdtAddMsg 245402, 10, '245402 IDHoldFailed',             'us_english', 1812
execute rdt.rdtAddMsg 245403, 10, '245403 LOCHoldFailed',            'us_english', 1812
execute rdt.rdtAddMsg 245404, 10, '245404 InventoryIssue',           'us_english', 1812
execute rdt.rdtAddMsg 239667, 10, '239667 More cabs task',           'us_english', 1812, 0, '239667 More cabs task'
execute rdt.rdtAddMsg 218265, 10, 'MHE not for FromLoc',             'us_english', 1812, 0, '218265^MHE not for FromLoc'

EXEC sp_addmessage 218265, 10, 'MHE not for FromLoc', 'us_english', 'FALSE';
