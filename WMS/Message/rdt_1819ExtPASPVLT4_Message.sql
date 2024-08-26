--Message file
--execute rdt.rdtdropmsg

execute rdt.rdtAddMsg 217987, 10, 'Multi SKU on pallet',     'us_english', 1819
execute rdt.rdtAddMsg 217988, 10, 'No Pick loc for SKU',     'us_english', 1819
execute rdt.rdtAddMsg 217989, 10, 'Unknown PA LPN type',     'us_english', 1819
execute rdt.rdtAddMsg 217990, 10, 'No PnD loc available',     'us_english', 1819
execute rdt.rdtAddMsg 217991, 10, 'No PA loc available',     'us_english', 1819

SELECT * FROM RDT.RDTMSG WITH(NOLOCK) WHERE Message_ID BETWEEN 217987 AND 217991
