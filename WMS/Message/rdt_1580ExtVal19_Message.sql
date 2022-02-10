--rdt_1580ExtVal19
execute rdt.rdtDropMsg 162051 , 162100

execute rdt.rdtAddMsg 162051, 10, '62051^Lottable01 req', 'us_english', 1580
execute rdt.rdtAddMsg 162052, 10, '62052^Lottable02 req', 'us_english', 1580
execute rdt.rdtAddMsg 162053, 10, '62053^Lottable03 req', 'us_english', 1580
execute rdt.rdtAddMsg 162054, 10, '62054^Lottable04 req', 'us_english', 1580

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 162051 AND 162100

