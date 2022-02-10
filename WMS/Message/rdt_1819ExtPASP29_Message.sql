--rdt_1819ExtPASP29
rdt.rdtDropMsg 151251 , 151300

execute rdt.rdtAddMsg 151251, 10, '51251^StrategyNotSet',   'us_english', 1819
execute rdt.rdtAddMsg 151252, 10, '51252^BadStrategyKey',   'us_english', 1819


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 151251 AND 151300