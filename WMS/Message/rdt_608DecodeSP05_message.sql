--rdt_608DecodeSP05
execute rdt.rdtDropMsg 203151 , 203200

execute rdt.rdtAddMsg 203151, 10, '203151EPCINMultiASN', 'us_english', 608
execute rdt.rdtAddMsg 203152, 10, '203152NeedScanSKU', 'us_english', 608
execute rdt.rdtAddMsg 203153, 10, '203153NeedScanEPC', 'us_english', 608
execute rdt.rdtAddMsg 203154, 10, '203154DuplicateSNo', 'us_english', 608
execute rdt.rdtAddMsg 203155, 10, '203155DuplicateSNo', 'us_english', 608