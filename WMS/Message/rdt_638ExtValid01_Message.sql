--rdt_638ExtValid01
rdt.rdtDropMsg 146351 , 146400

execute rdt.rdtAddMsg 146351, 10, '46351^Invalid SKU',   'us_english', 638
execute rdt.rdtAddMsg 146352, 10, '46352^Non LF Item',   'us_english', 638
execute rdt.rdtAddMsg 146353, 10, '46353^Non LF Item',   'us_english', 638
execute rdt.rdtAddMsg 146354, 10, '46354^Nothing2Final', 'us_english', 638

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 146351 AND 146400