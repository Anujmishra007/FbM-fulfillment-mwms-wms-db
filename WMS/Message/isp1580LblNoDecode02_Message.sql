--isp1580LblNoDecode02
execute rdt.rdtDropMsg 126551, 126600


execute rdt.rdtAddMsg 126551, 10, '26551^SKU is blank',     'us_english', 1580
execute rdt.rdtAddMsg 126552, 10, '26552^Season IsBlank',   'us_english', 1580
execute rdt.rdtAddMsg 126553, 10, '26553^LOT Is Blank',     'us_english', 1580
execute rdt.rdtAddMsg 126554, 10, '26554^COO Is Blank',     'us_english', 1580
execute rdt.rdtAddMsg 126555, 10, '26555^SKU Not In ASN',   'us_english', 1580
execute rdt.rdtAddMsg 126556, 10, '26556^SeasonNotInASN',   'us_english', 1580
execute rdt.rdtAddMsg 126557, 10, '26557^LOT Not In L02',   'us_english', 1580
execute rdt.rdtAddMsg 126558, 10, '26558^COO Not In L02',   'us_english', 1580


SELECT * FROM RDT.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 126551 AND 126600