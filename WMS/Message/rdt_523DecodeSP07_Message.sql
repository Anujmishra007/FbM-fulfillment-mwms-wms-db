-- rdt_523DecodeSP07
execute rdt.rdtDropMsg 253801, 253850

execute rdt.rdtAddMsg 253801, 10, '253801InvalidBarcode', 'us_english', 523
execute rdt.rdtAddMsg 253802, 10, '253802Invalid SKU   ', 'us_english', 523
execute rdt.rdtAddMsg 253803, 10, '253803Multi SKU     ', 'us_english', 523
