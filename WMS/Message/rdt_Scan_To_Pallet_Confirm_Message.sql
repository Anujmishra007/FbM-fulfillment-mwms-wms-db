--rdt_Scan_To_Pallet_Confirm
execute rdt.rdtdropmsg 152151, 152200

execute rdt.rdtAddMsg 152151, 10, '152151Ins PLTDt Fail', 'us_english', 1638
execute rdt.rdtAddMsg 152152, 10, '152152INSPackInfFail', 'us_english', 1638
execute rdt.rdtAddMsg 152153, 10, '152153INSPackInfFail', 'us_english', 1638
execute rdt.rdtAddMsg 152154, 10, '152154UPDPackInfFail', 'us_english', 1638
