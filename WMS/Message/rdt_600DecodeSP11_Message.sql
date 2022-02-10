--rdt_600DecodeSP11
exec rdt.rdtDropMsg 177401 , 177450	
	
execute rdt.rdtAddMsg 177401, 10, '177401 Invalid SKU  ', 'us_english', 600
execute rdt.rdtAddMsg 177402, 10, '177402 Invalid Lot01', 'us_english', 600

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 177401 AND 177450	