--rdt_1768ExtInfo05
execute rdt.rdtDropMsg 204851 , 204900

execute rdt.rdtAddMsg 204851, 10, 'SYSTEM QTY          ',   'us_english', 1768
execute rdt.rdtAddMsg 204852, 10, 'NOT TALLY WITH      ',   'us_english', 1768
execute rdt.rdtAddMsg 204853, 10, 'ACTUAL CC QTY       ',   'us_english', 1768


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 204851 AND 204900