-- rdt_1580ExtVal22
execute rdt.rdtDropMsg 162551, 162600

execute rdt.rdtAddMsg 162551, 10, '162551^ Wrong Loc   ', 'us_english', 1580

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 162551 and 162600
