-- rdt_1841ExtValid07
execute rdt.rdtDropMsg 214951 , 215000

execute rdt.rdtAddMsg 214951, 10, '214951 Exceed QtyExp', 'us_english', 1841


SELECT * FROM RDT.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 214951 AND 215000
