--Message file
--execute rdt.rdtdropmsg

execute rdt.rdtAddMsg 217985, 10, 'LPN is in multi locs',     'us_english', 1819
execute rdt.rdtAddMsg 217986, 10, 'LPN not in a PA loc',     'us_english', 1819

SELECT * FROM RDT.RDTMSG WITH(NOLOCK) WHERE Message_ID BETWEEN 217985 AND 217986