-- rdt_840ExtValid07
execute rdt.rdtDropMsg 149751 , 149800

execute rdt.rdtAddMsg 149751, 10, '49751^INV CTN TYPE',     'us_english', 840

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 149751 AND 149800
