--rdt_1819ExtPASP22
execute rdt.rdtdropmsg 134151, 134200

execute rdt.rdtAddMsg 134151, 10, '34151^No PA Zone',     'us_english', 1819
execute rdt.rdtAddMsg 134152, 10, '34152^No Suggest Loc', 'us_english', 1819


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 134151 AND 134200
