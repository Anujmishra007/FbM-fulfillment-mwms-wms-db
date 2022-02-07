--rdt_841GetOrders06
rdt.rdtDropMsg 153151 , 153200

execute rdt.rdtAddMsg 153151, 10, '53151^Ins Ecomm Fail',   'us_english', 841
execute rdt.rdtAddMsg 153152, 10, '53152^NoRecToProcess',   'us_english', 841

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 153151 AND 153200