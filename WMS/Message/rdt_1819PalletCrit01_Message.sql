--rdt_1819PalletCrit01
execute rdt.rdtdropmsg 134051, 134100

execute rdt.rdtAddMsg 134051, 10, 'INVALID COLUMN NAME', 'us_english', 1819
execute rdt.rdtAddMsg 134052, 10, 'VALUE REQUIRED FOR ', 'us_english', 1819
execute rdt.rdtAddMsg 134053, 10, 'VALUE NOT EXISTS   ', 'us_english', 1819

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 134051 AND 134100
