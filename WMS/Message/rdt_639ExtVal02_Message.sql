--rdt_639ExtVal02
execute rdt.rdtdropmsg 162351 , 162400	

execute rdt.rdtAddMsg 162351, 10, '62351^QTY <> CASECNT',   'us_english', 639
execute rdt.rdtAddMsg 162352, 10, '62352^NOLABELPRINTER',   'us_english', 639

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 162351 AND 162400