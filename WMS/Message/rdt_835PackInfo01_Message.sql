--rdt_835PackInfo01
rdt.rdtDropMsg 177351 , 177400	

execute rdt.rdtAddMsg 177351, 10, '177351 UPDPackInfErr',   'us_english', 835
execute rdt.rdtAddMsg 177352, 10, '177352 UPDPackInfErr',   'us_english', 835

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 177351 AND 177400