--rdt_1855ExtUpd02
exec rdt.rdtDropMsg 208501 , 208550

execute rdt.rdtAddMsg 208501, 10, '208501 ORDERS CANCEL',   'us_english', 1855
execute rdt.rdtAddMsg 208502, 10, '208502 UPD ORD Fail ',   'us_english', 1855
execute rdt.rdtAddMsg 208503, 10, '208503 UPD ORDDt ERR',   'us_english', 1855
execute rdt.rdtAddMsg 208504, 10, '208502 InsTL2Log Err',   'us_english', 1855
execute rdt.rdtAddMsg 208505, 10, '208503 GetKey Fail ',    'us_english', 1855
execute rdt.rdtAddMsg 208506, 10, '208504 INS TCPOUT Er',   'us_english', 1855
execute rdt.rdtAddMsg 208507, 10, '208505 UPD TCPOUT Er',   'us_english', 1855
execute rdt.rdtAddMsg 208508, 10, '208506 UPD TL2 Fail ',   'us_english', 1855
execute rdt.rdtAddMsg 208509, 10, '208507 SendEmailErrl',   'us_english', 1855
execute rdt.rdtAddMsg 208510, 10, '208510 WCS Send Fail',   'us_english', 1855
execute rdt.rdtAddMsg 208511, 10, '208511 UPD TL2 Fail ',   'us_english', 1855

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 208501 AND 208550


