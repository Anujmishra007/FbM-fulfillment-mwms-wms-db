-- rdt_513ExtVal11
execute rdt.rdtDropMsg 227801, 227850

execute rdt.rdtAddMsg 227801, 10, '227801ToID in used',           'us_english', 513

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 227801 AND 227850