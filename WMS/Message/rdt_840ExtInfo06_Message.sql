--rdt_840ExtInfo06
execute rdt.rdtDropMsg 160201 , 160250

execute rdt.rdtAddMsg 160201, 10, 'ORDERS SHORT PICK',     'us_english', 840

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 160201 AND 160250
