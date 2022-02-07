--rdt_523ExtValidSP07
rdt.rdtDropMsg 145851 , 145900

execute rdt.rdtAddMsg 145851, 10, '45851^Invalid SKU',      'us_english', 523
execute rdt.rdtAddMsg 145852, 10, '45852^Invalid SKU',      'us_english', 523
execute rdt.rdtAddMsg 145853, 10, '45853^PAQty Not Enuf',   'us_english', 523

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 145851 AND 145900