--rdt_1580DecodeSN02
execute rdt.rdtDropMsg 198301 , 198350

execute rdt.rdtAddMsg 198301, 10, '198301SerialNoExists', 'us_english', 1580
execute rdt.rdtAddMsg 198302, 10, '198302InvalidSerial#', 'us_english', 1580
execute rdt.rdtAddMsg 198303, 10, '198303 SKU NotIn UCC', 'us_english', 1580
execute rdt.rdtAddMsg 198304, 10, '198304 InsertLog Err', 'us_english', 1580
execute rdt.rdtAddMsg 198305, 10, '198305SerialNoExists', 'us_english', 1580

--Addhoc fix
execute rdt.rdtAddMsg 198306, 10, '198306InvalidSerial#', 'us_english', 1580
execute rdt.rdtAddMsg 198307, 10, '198307 Qty Not Tally', 'us_english', 1580

-- WMS-22488
execute rdt.rdtAddMsg 198308, 10, '198308 SNo Received ', 'us_english', 1580
execute rdt.rdtAddMsg 198309, 10, '198309 SNo Exists   ', 'us_english', 1580

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 198301 AND 198350