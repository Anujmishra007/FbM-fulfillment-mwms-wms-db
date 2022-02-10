--rdt_1819ExtPASP25
rdt.rdtDropMsg 140951 , 141000

execute rdt.rdtAddMsg 140951, 10, '40951^StrategyNotSet',   'us_english', 1819
execute rdt.rdtAddMsg 140952, 10, '40952^BadStrategyKey',   'us_english', 1819
execute rdt.rdtAddMsg 140953, 10, '40953^No Sugg Loc',      'us_english', 1819

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 140951 AND 141000