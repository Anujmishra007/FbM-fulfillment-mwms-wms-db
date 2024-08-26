--Message file
--execute rdt.rdtdropmsg

execute rdt.rdtAddMsg 218000, 10, 'Confirm qty as shown',     'us_english', 830

SELECT * FROM RDT.RDTMSG WITH(NOLOCK) WHERE Message_ID BETWEEN 218000 AND 218000
