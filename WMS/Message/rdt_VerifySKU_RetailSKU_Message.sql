--rdt_VerifySKU_RetailSKU
execute rdt.rdtDropMsg 102451, 102500

execute rdt.rdtAddMsg 102451, 10, '02451 Need Barcode  ', 'us_english'
execute rdt.rdtAddMsg 102452, 10, '02452 MultiSKUBarcod', 'us_english'
execute rdt.rdtAddMsg 102453, 10, '02453 BarcodeAdyUsed', 'us_english'
