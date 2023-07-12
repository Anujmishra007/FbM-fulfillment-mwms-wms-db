--rdt_1580DecodeSP03
rdt.rdtDropMsg 203251 , 203300

execute rdt.rdtAddMsg 203251, 10, '203251 SKU NotIn ASN',   'us_english', 1580
execute rdt.rdtAddMsg 203252, 10, '203252 SKU Over Rcv ',   'us_english', 1580

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 203251 AND 203300