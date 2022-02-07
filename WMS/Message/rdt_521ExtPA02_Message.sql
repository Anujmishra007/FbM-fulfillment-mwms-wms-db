--rdt_521ExtPA03
exec rdt.rdtDropMsg 114101 , 114150

execute rdt.rdtAddMsg 114101, 10, '14101^Mix Division',     'us_english', 521
execute rdt.rdtAddMsg 114102, 10, '14102^Mix Stock Type',   'us_english', 521
execute rdt.rdtAddMsg 114103, 10, '14103^No Stock Type',    'us_english', 521
execute rdt.rdtAddMsg 114104, 10, '14104^StrategyNotSet',   'us_english', 521
execute rdt.rdtAddMsg 114105, 10, '14105^No PA Zone',       'us_english', 521

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 114101 AND 114150

