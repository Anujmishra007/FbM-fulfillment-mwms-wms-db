--rdt_1580DecodeSP02
execute rdt.rdtDropMsg 203101 , 203150

execute rdt.rdtAddMsg 203101, 10, '203101EPCINMultiASN', 'us_english', 1580
execute rdt.rdtAddMsg 203102, 10, '203102NeedScanSKU', 'us_english', 1580
execute rdt.rdtAddMsg 203103, 10, '203103NeedScanEPC', 'us_english', 1580
execute rdt.rdtAddMsg 203104, 10, '203104DuplicateSNo', 'us_english', 1580
