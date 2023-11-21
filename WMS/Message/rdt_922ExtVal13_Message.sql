--rdt_922ExtVal13
execute rdt.rdtdropmsg 207951 , 208000	

execute rdt.rdtAddMsg 207951, 10, 'ID Status:          ',   'us_english', 922

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 207951 AND 208000