--rdt_1819ExtUpd01
execute rdt.rdtdropmsg 52851, 52900

execute rdt.rdtAddMsg 52851, 10, '52851^DEL DID Fail  ', 'us_english', 1819
execute rdt.rdtAddMsg 52852, 10, '52852^UPD ID Fail   ', 'us_english', 1819
execute rdt.rdtAddMsg 52853, 10, '52853^UPD Task Fail ', 'us_english', 1819

--365488
execute rdt.rdtAddMsg 52854, 10, '52854^UNHOLD ID Fail ', 'us_english', 1819
execute rdt.rdtAddMsg 52855, 10, '52855^UNHOLD ID Fail ', 'us_english', 1819