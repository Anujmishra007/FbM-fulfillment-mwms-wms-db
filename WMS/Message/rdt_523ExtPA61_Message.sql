--rdt_523ExtPA61
rdt.rdtDropMsg 203451 , 203500

execute rdt.rdtAddMsg 203451, 10, '203451 No Lottable08',   'us_english', 523
execute rdt.rdtAddMsg 203452, 10, '203452 No PA Zone   ',   'us_english', 523
execute rdt.rdtAddMsg 203453, 10, '203453No Suggest Loc',   'us_english', 523


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 203451 AND 203500