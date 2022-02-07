--rdt_LottableFormat_DoterraReturnCheckLottable
exec rdt.rdtDropMsg 145351 , 145400

execute rdt.rdtAddMsg 145351, 10, '45351^Invalid Lot03',    'us_english', 608
execute rdt.rdtAddMsg 145352, 10, '45352^Invalid Lot04',    'us_english', 608


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 145351 AND 145400

