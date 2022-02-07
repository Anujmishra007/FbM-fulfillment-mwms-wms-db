--rdt_608ExtVal09
execute rdt.rdtDropMsg 162001, 162050	

execute rdt.rdtAddMsg 162001, 10, '162001NoMixSKUinID  ', 'us_english', 608
execute rdt.rdtAddMsg 162002, 10, '162002Over Receive  ', 'us_english', 608
execute rdt.rdtAddMsg 162003, 10, '162003NotAllowAddSKU', 'us_english', 608
execute rdt.rdtAddMsg 162004, 10, '162004NoMixL01inID  ', 'us_english', 608

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 162001 AND 162050
