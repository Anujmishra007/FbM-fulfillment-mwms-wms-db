--rdt_640ExtUpd01
exec rdt.rdtDropMsg 177251 , 177300

execute rdt.rdtAddMsg 177251, 10, '177251 InsTL2Log Err',   'us_english', 640
execute rdt.rdtAddMsg 177252, 10, '177252 GetKey Fail',     'us_english', 640
execute rdt.rdtAddMsg 177253, 10, '177253 INS TCPOUT Er',   'us_english', 640
execute rdt.rdtAddMsg 177254, 10, '177254 UPD TCPOUT Er',   'us_english', 640
execute rdt.rdtAddMsg 177255, 10, '177255 UPD TL2 Fail',    'us_english', 640
execute rdt.rdtAddMsg 177256, 10, '177256 SendEmail Err',   'us_english', 640
execute rdt.rdtAddMsg 177257, 10, '177257 WCS Send Fail',   'us_english', 640
execute rdt.rdtAddMsg 177258, 10, '177258 UPD TL2 Fail',    'us_english', 640

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 177251 AND 177300


