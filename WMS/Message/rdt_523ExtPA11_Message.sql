--rdt_523ExtPA11
exec rdt.rdtDropMsg 114051 , 114100

execute rdt.rdtAddMsg 114051, 10, '14051^Mix Division',     'us_english', 523
execute rdt.rdtAddMsg 114052, 10, '14052^Mix Stock Type',   'us_english', 523
execute rdt.rdtAddMsg 114053, 10, '14053^No Stock Type',    'us_english', 523
execute rdt.rdtAddMsg 114054, 10, '14054^StrategyNotSet',   'us_english', 523
execute rdt.rdtAddMsg 114055, 10, '14055^No PA Zone',       'us_english', 523

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 114051 AND 114100

