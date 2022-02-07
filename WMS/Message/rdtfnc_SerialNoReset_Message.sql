-- rdtfnc_SerialNoReset
execute rdt.rdtDropMsg 75201, 75250

execute rdt.rdtAddMsg 75201, 10, '75201^PS# Required',   'us_english'
execute rdt.rdtAddMsg 75202, 10, '75202^Invalid PS#',    'us_english'
execute rdt.rdtAddMsg 75203, 10, '75203^PS Not Scan In', 'us_english'
execute rdt.rdtAddMsg 75204, 10, '75204^PS Not ScanOut', 'us_english'
execute rdt.rdtAddMsg 75205, 10, '75205^DiscretePSOnly', 'us_english'
execute rdt.rdtAddMsg 75206, 10, '75206^Invalid SKU',    'us_english'
execute rdt.rdtAddMsg 75207, 10, '75207^Option needed',  'us_english'
execute rdt.rdtAddMsg 75208, 10, '75208^Invalid option', 'us_english'
execute rdt.rdtAddMsg 75209, 10, '75209^Del SNO Fail',   'us_english'
execute rdt.rdtAddMsg 75210, 10, '75210^Order shipped',  'us_english'