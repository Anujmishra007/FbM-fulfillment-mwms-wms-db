--rdt_598ExtValid01
rdt.rdtDropMsg 170751 , 170800

execute rdt.rdtAddMsg 170751, 10, '170751 Over Received',   'us_english', 598
execute rdt.rdtAddMsg 170752, 10, '170752 No Mix Dvs   ',   'us_english', 598


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 170751 AND 170800