--Message file
--execute rdt.rdtdropmsg

execute rdt.rdtAddMsg 217984, 10, 'Sku not set for loc',     'us_english', 513


SELECT * FROM RDT.RDTMSG WITH(NOLOCK) WHERE Message_ID BETWEEN 217984 AND 217984
