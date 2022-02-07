--rdt_1819ExtPASP27
rdt.rdtDropMsg 149251 , 149300

execute rdt.rdtAddMsg 149251, 10, '49251^NotFull Pallet',   'us_english', 1819
execute rdt.rdtAddMsg 149252, 10, '49252^BadStrategyKey',   'us_english', 1819
execute rdt.rdtAddMsg 149253, 10, '49253^BadStrategyKey',   'us_english', 1819
execute rdt.rdtAddMsg 149254, 10, '49254^No Sugg Loc',      'us_english', 1819

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 149251 AND 149300