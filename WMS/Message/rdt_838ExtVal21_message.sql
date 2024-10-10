-- rdt_838ExtVal21
execute rdt.rdtDropMsg 225951  , 226000		

execute rdt.rdtAddMsg 225951, 10, '225951Not allow Mix SKU', 'us_english', 838


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 225951 AND 226000
