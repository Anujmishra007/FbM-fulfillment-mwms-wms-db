--Message file
--execute rdt.rdtdropmsg

execute rdt.rdtAddMsg 218001, 10, 'Unknown PA LPN type',     'us_english', 1819
execute rdt.rdtAddMsg 218002, 10, 'Unsuitable location',     'us_english', 1819

SELECT * FROM RDT.RDTMSG WITH(NOLOCK) WHERE Message_ID BETWEEN 218001 AND 218002
