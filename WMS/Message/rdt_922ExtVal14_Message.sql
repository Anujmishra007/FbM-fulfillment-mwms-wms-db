--rdt_922ExtVal14
execute rdt.rdtdropmsg 220501, 220550
	
execute rdt.rdtAddMsg 220501, 10, '220501NeedRefNo',   'us_english', 922, 0, 'RefNo is required'
execute rdt.rdtAddMsg 220502, 10, '220502NeedRefNo2',   'us_english', 922, 0, 'RefNo2 is required'

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 220501 AND 220550