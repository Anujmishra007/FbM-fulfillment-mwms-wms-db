

-- rdt_830DecodeSP01
execute rdt.rdtDropMsg 160001  , 160050

execute rdt.rdtAddMsg 160001, 10, '160001InvalidSKU', 'us_english', 830
execute rdt.rdtAddMsg 160002, 10, '160002InvalidSKU', 'us_english', 830