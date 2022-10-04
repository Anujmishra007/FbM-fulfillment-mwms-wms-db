--rdt_638ExtValid09
rdt.rdtDropMsg 190301 , 190350

execute rdt.rdtAddMsg 190301, 10, '190301Invalid SKU',   'us_english', 638
execute rdt.rdtAddMsg 190302, 10, '190302Non LF Item',   'us_english', 638
execute rdt.rdtAddMsg 190303, 10, '190303Non LF Item',   'us_english', 638
execute rdt.rdtAddMsg 190304, 10, '190304Nothing2Final', 'us_english', 638
execute rdt.rdtAddMsg 190305, 10, '190305Nothing2Final', 'us_english', 638

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 190301 AND 190350