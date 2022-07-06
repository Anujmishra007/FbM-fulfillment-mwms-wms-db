--rdt_1855ExtUpd01
exec rdt.rdtDropMsg 177301 , 177350

execute rdt.rdtAddMsg 177301, 10, '177301 InsTL2Log Err',   'us_english', 1855
execute rdt.rdtAddMsg 177302, 10, '177302 GetKey Fail ',    'us_english', 1855
execute rdt.rdtAddMsg 177303, 10, '177303 INS TCPOUT Er',   'us_english', 1855
execute rdt.rdtAddMsg 177304, 10, '177304 UPD TCPOUT Er',   'us_english', 1855
execute rdt.rdtAddMsg 177305, 10, '177305 UPD TL2 Fail ',   'us_english', 1855
execute rdt.rdtAddMsg 177306, 10, '177306 SendEmailErrl',   'us_english', 1855
execute rdt.rdtAddMsg 177307, 10, '177307 WCS Send Fail',   'us_english', 1855
execute rdt.rdtAddMsg 177308, 10, '177308 UPD TL2 Fail ',   'us_english', 1855

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 177301 AND 177350


