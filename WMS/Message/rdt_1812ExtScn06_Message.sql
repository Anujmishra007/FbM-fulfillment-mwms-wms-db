-- rdt_1812ExtScn06
execute rdt.rdtDropMsg 245401 , 245450

execute rdt.rdtAddMsg 245401, 10, '245401 InventoryHoldFailed',    'us_english', 1812
execute rdt.rdtAddMsg 245402, 10, '245402 IDHoldFailed',    'us_english', 1812
execute rdt.rdtAddMsg 245403, 10, '245403 LOCHoldFailed',    'us_english', 1812
execute rdt.rdtAddMsg 245404, 10, '245404 InventoryIssue',    'us_english', 1812

EXEC sp_addmessage 218244, 10, '218244^MHE not for Area', 'us_english', 'FALSE';
EXEC sp_addmessage 218245, 10, '218245^Tasks big for MHE', 'us_english', 'FALSE';