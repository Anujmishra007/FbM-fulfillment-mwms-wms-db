--rdt_841GetOrders08
rdt.rdtDropMsg 170151 , 170200	

execute rdt.rdtAddMsg 170151, 10, '170151Ins Ecomm Fail',   'us_english', 841
execute rdt.rdtAddMsg 170152, 10, '170152NoRecToProcess',   'us_english', 841

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 170151 AND 170200