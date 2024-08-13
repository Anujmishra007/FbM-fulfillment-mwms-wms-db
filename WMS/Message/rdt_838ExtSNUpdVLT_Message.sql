--Message file
--execute rdt.rdtdropmsg

execute rdt.rdtAddMsg 218003, 10, 'SN is already used',     'us_english', 838

SELECT * FROM RDT.RDTMSG WITH(NOLOCK) WHERE Message_ID BETWEEN 218003 AND 218003
