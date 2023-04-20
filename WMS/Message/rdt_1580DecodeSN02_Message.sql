--rdt_1580DecodeSN02
execute rdt.rdtDropMsg 198301 , 198350

execute rdt.rdtAddMsg 198301, 10, '198301SerialNoExists', 'us_english', 1580
execute rdt.rdtAddMsg 198302, 10, '198302InvalidSerial#', 'us_english', 1580
execute rdt.rdtAddMsg 198303, 10, '198303 SKU NotIn UCC', 'us_english', 1580
execute rdt.rdtAddMsg 198304, 10, '198304 InsertLog Err', 'us_english', 1580
execute rdt.rdtAddMsg 198305, 10, '198305SerialNoExists', 'us_english', 1580

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 198301 AND 198350