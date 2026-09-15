-- rdt_523DecodeSP07
execute rdt.rdtDropMsg 253801, 253850

execute rdt.rdtAddMsg 253801, 10, '253801InvalidBarcode', 'us_english', 523, 0, '253801 Invalid barcode'
execute rdt.rdtAddMsg 253802, 10, '253802Invalid SKU   ', 'us_english', 523, 0, '253802 Invalid SKU'
execute rdt.rdtAddMsg 253803, 10, '253803Multi SKU     ', 'us_english', 523, 0, '253803 Multi SKU barcode'
execute rdt.rdtAddMsg 253804, 10, '253804L01 NotInLOCID', 'us_english', 523, 0, '253804 Lottable01 not in LOC and/or ID'
