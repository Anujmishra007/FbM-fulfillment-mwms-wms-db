--rdt_1819ExtPASP11
exec rdt.rdtDropMsg 109301 , 109350

execute rdt.rdtAddMsg 109301, 10, '09301^Mix Division',     'us_english', 1819
execute rdt.rdtAddMsg 109302, 10, '09302^Mix Stock Type',   'us_english', 1819
execute rdt.rdtAddMsg 109303, 10, '09303^No Stock Type',    'us_english', 1819
execute rdt.rdtAddMsg 109304, 10, '09304^StrategyNotSet',   'us_english', 1819
execute rdt.rdtAddMsg 109305, 10, '09305^No PA Zone',       'us_english', 1819

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 109301 AND 109350

