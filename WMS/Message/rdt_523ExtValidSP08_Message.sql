--rdt_523ExtValidSP08
rdt.rdtDropMsg 148051 , 148100

execute rdt.rdtAddMsg 148051, 10, '148051^Invalid Loc',      'us_english', 523
execute rdt.rdtAddMsg 148052, 10, '148052DiffLottable01',      'us_english', 523

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 148051 AND 148100