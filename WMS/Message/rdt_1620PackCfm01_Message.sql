--rdt_1620PackCfm01
execute rdt.rdtDropMsg 143301, 143350

execute rdt.rdtAddMsg 143301, 10, '43301^No Pickslip',   'us_english', 1620
execute rdt.rdtAddMsg 143302, 10, '43302^PackCfm Fail',  'us_english', 1620


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 143301 AND 143350
