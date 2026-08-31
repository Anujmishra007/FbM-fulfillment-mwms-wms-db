-- rdt_523DecodeSN01
execute rdt.rdtDropMsg 266301, 266350

execute rdt.rdtAddMsg 266301, 10, '266301InvalidBarcode', 'us_english', 523
execute rdt.rdtAddMsg 266302, 10, '266302Invalid SKU   ', 'us_english', 523
execute rdt.rdtAddMsg 266303, 10, '266303Multi SKU     ', 'us_english', 523
execute rdt.rdtAddMsg 266304, 10, '266304InvalidBarcode', 'us_english', 523
execute rdt.rdtAddMsg 266305, 10, '266305Different SKU ', 'us_english', 523
