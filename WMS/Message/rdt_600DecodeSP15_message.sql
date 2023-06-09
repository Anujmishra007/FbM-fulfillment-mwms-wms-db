

-- rdt_600DecodeSP15
execute rdt.rdtDropMsg 200601, 200650

execute rdt.rdtAddMsg 200601, 10, '200601InvalidSKU',    'us_english',600
execute rdt.rdtAddMsg 200602, 10, '200602DuplicatePlt',    'us_english',600
execute rdt.rdtAddMsg 200603, 10, '200603IDMoreThanLot2',    'us_english',600