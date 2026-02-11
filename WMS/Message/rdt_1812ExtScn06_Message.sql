-- rdt_1812ExtScn06
execute rdt.rdtDropMsg 245401 , 245450

execute rdt.rdtAddMsg 245401, 10, '245401 InventoryHoldFailed',      'us_english', 1812
execute rdt.rdtAddMsg 245402, 10, '245402 IDHoldFailed',             'us_english', 1812
execute rdt.rdtAddMsg 245403, 10, '245403 LOCHoldFailed',            'us_english', 1812
execute rdt.rdtAddMsg 245404, 10, '245404 InventoryIssue',           'us_english', 1812
execute rdt.rdtAddMsg 239667, 10, '239667 More cabs task',           'us_english', 1812, 0, '239667 More cabs task'

EXEC sp_addmessage 218244, 10, '218244^MHE not for Area',            'us_english', 'FALSE'
EXEC sp_addmessage 218245, 10, '218245^Tasks big for MHE',           'us_english', 'FALSE'
EXEC sp_addmessage 218262, 10, '218262^Order in progress',           'us_english', 'FALSE'
EXEC sp_addmessage 218263, 10, '218263^NoPermissions',               'us_english', 'FALSE'
