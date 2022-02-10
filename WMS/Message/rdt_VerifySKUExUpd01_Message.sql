--rdt_VerifySKUExUpd01
execute rdt.rdtDropMsg 91851, 91900

execute rdt.rdtAddMsg 91851, 10, '91851 Need Barcode  ', 'us_english'
execute rdt.rdtAddMsg 91852, 10, '91852 MultiSKUBarcod', 'us_english'
execute rdt.rdtAddMsg 91853, 10, '91853 BarcodeAdyUsed', 'us_english'
