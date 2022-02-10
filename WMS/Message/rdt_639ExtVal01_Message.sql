--rdt_639ExtVal01
execute rdt.rdtdropmsg 148501 , 148550	

execute rdt.rdtAddMsg 148501, 10, '48501^Mix Lottable01',   'us_english', 639
execute rdt.rdtAddMsg 148502, 10, '48502^Mix Lottable08',   'us_english', 639
execute rdt.rdtAddMsg 148503, 10, '48503^Mix Lottable09',   'us_english', 639
execute rdt.rdtAddMsg 148504, 10, '48504^Inv Lottable',     'us_english', 639

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 148501 AND 148550