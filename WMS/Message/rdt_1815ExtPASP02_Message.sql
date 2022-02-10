-- rdt_1815ExtPA02
rdt.rdtDropMsg 172801, 172850

execute rdt.rdtAddMsg 172801, 10, '172801StrategyNotSet',    'us_english', 1815
execute rdt.rdtAddMsg 172802, 10, '172802BadStrategyKey',    'us_english', 1815
execute rdt.rdtAddMsg 172803, 10, '172803^NoSuitableLOC',    'us_english', 1815
execute rdt.rdtAddMsg 172804, 10, '172804^UPD Task Fail',    'us_english', 1815
execute rdt.rdtAddMsg 172805, 10, '172805^Invalid ToLoc',    'us_english', 1815


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 172801 AND 172850