--rdt_1819ExtPASP12
exec rdt.rdtDropMsg 122451 , 122500

execute rdt.rdtAddMsg 122451, 10, '22451^Mix Division',     'us_english', 1819
execute rdt.rdtAddMsg 122452, 10, '22452^ID In >1 Loc',     'us_english', 1819
execute rdt.rdtAddMsg 122453, 10, '22453^No PA Zone',       'us_english', 1819

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 122451 AND 122500

