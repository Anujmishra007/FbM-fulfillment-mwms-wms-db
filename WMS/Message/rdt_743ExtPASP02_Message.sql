-- rdt_743ExtPASP02 
execute rdt.rdtDropMsg 111151 , 111200

execute rdt.rdtAddMsg 111151, 10, '11151^No Home Loc',   'us_english', 743

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 111151 AND 111200