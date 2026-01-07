-- rdt_513DecodeSP06
execute rdt.rdtDropMsg 254201, 254250

execute rdt.rdtAddMsg 254201, 10, '254201InvalidBarcode', 'us_english', 513
execute rdt.rdtAddMsg 254202, 10, '254202Invalid SKU   ', 'us_english', 513
execute rdt.rdtAddMsg 254203, 10, '254203Multi SKU     ', 'us_english', 513
execute rdt.rdtAddMsg 254204, 10, '254204No QTY to move', 'us_english', 513
execute rdt.rdtAddMsg 254205, 10, '254205InvalidBarcode', 'us_english', 513
