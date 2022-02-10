--rdt_1620DecodeSP03
execute rdt.rdtDropMsg 151901 , 151950

execute rdt.rdtAddMsg 151901, 10, '51901^Invalid SKU',   'us_english', 1620


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 151901 AND 151950