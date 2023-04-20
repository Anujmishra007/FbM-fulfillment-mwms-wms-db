--rdt_1580DecodeSP01
execute rdt.rdtDropMsg 197851 , 197900

execute rdt.rdtAddMsg 197851, 10, '197851 Need Scan EPC', 'us_english', 1580
execute rdt.rdtAddMsg 197852, 10, '197852SKU Not In EPC', 'us_english', 1580

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 197851 AND 197900