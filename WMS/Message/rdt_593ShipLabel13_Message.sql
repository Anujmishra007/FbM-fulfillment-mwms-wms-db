--rdt_593ShipLabel13
rdt.rdtDropMsg 179301 , 179350

execute rdt.rdtAddMsg 179301, 10, '179301 Bad OrderKey ',   'us_english', 593


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 179251 AND 179350