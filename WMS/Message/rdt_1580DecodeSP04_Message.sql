--rdt_1580DecodeSP04
rdt.rdtDropMsg 220701 , 220750

execute rdt.rdtAddMsg 220701, 10, '220701 Invalid SKU',   'us_english', 1580
execute rdt.rdtAddMsg 220702, 10, '220702 SKU NotIn ASN',   'us_english', 1580
execute rdt.rdtAddMsg 220703, 10, '220703 SKU Over Rcv ',   'us_english', 1580
execute rdt.rdtAddMsg 220704, 10, '220704 Invalid SerialNo ',   'us_english', 1580
execute rdt.rdtAddMsg 220705, 10, '220705 SN received ',   'us_english', 1580

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 220701 AND 220750