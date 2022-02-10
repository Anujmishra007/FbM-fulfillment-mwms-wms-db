-- rdt_1580RefNoLKUP02
execute rdt.rdtDropMsg 119951, 120000

execute rdt.rdtAddMsg 119951, 10, '19951^Invalid ExtASN', 'us_english', 1580
execute rdt.rdtAddMsg 119952, 10, '19952^ExtASNNotInASN', 'us_english', 1580

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 119951 AND 120000
