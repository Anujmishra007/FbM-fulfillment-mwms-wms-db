--rdt_841GetOrders07
rdt.rdtDropMsg 167051 , 167100	

execute rdt.rdtAddMsg 167051, 10, '167051Not Yet Picked',   'us_english', 841
execute rdt.rdtAddMsg 167052, 10, '167052Ins Ecomm Fail',   'us_english', 841
execute rdt.rdtAddMsg 167053, 10, '167053NoRecToProcess',   'us_english', 841

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 167051 AND 167100