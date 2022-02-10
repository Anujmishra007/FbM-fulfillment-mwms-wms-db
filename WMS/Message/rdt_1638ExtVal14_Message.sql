--rdt_1638ExtVal14
exec rdt.rdtDropMsg 178251 , 178300	
	
execute rdt.rdtAddMsg 178251, 10, '178251 Diff Country ', 'us_english', 1638
execute rdt.rdtAddMsg 178252, 10, '178252 Diff Ord Type', 'us_english', 1638

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 178251 AND 178300	