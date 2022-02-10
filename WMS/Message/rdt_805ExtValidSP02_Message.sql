--rdt_805ExtValidSP02
rdt.rdtDropMsg 167801 , 167850	

execute rdt.rdtAddMsg 167801, 10, '167801 Device ID req',    'us_english', 805

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 167801 AND 167850