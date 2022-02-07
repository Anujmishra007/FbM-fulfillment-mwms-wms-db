-- rdt_Replenish_Confirm
exec rdt.rdtDropMsg 117051, 117100

execute rdt.rdtAddMsg 117051, 10, '117051Upd RPL Fail', 'us_english', 510
execute rdt.rdtAddMsg 117052, 10, '117052Offset error', 'us_english', 510
execute rdt.rdtAddMsg 117053, 10, '117053Upd RPL Fail', 'us_english', 510

-- WMS-11213
execute rdt.rdtAddMsg 117054, 10, '117054CannotMvQtyAlc', 'us_english', 510
execute rdt.rdtAddMsg 117055, 10, '117055CannotMvQtyAlc', 'us_english', 510
execute rdt.rdtAddMsg 117056, 10, '117056Upd RPL Fail',   'us_english', 510
execute rdt.rdtAddMsg 117057, 10, '117057Upd RPL Fail',   'us_english', 510
execute rdt.rdtAddMsg 117058, 10, '117058Upd RPL Fail',   'us_english', 510
execute rdt.rdtAddMsg 117059, 10, '117059Upd RPL Fail',   'us_english', 510
