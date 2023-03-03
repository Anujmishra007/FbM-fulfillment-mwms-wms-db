-- rdt_638ExtValid05
exec rdt.rdtdropmsg 158351, 158400

execute rdt.rdtAddMsg 158351, 10, '158351RFID ASN      ', 'us_english', 638
execute rdt.rdtAddMsg 158352, 10, 'BLACK LIST          ', 'us_english', 638
execute rdt.rdtAddMsg 158353, 10, 'BP#1 SKU            ', 'us_english', 638
execute rdt.rdtAddMsg 158354, 10, 'BP#2 SKU            ', 'us_english', 638
execute rdt.rdtAddMsg 158355, 10, 'RFID SKU            ', 'us_english', 638
execute rdt.rdtAddMsg 158356, 10, 'SET SKU             ', 'us_english', 638

-- WMS-16163
execute rdt.rdtAddMsg 158357, 10, '158357OVER 14 DAYS  ', 'us_english', 638

-- WMS-16506
execute rdt.rdtAddMsg 158358, 10, '158358ASN InProgress', 'us_english', 638
execute rdt.rdtAddMsg 158359, 10, 'GROUP LIST          ', 'us_english', 638

-- WMS-16735
execute rdt.rdtAddMsg 158360, 10, 'Program Order       ', 'us_english', 638
execute rdt.rdtAddMsg 158361, 10, 'Must Receive        ', 'us_english', 638
execute rdt.rdtAddMsg 158362, 10, 'Program Order       ', 'us_english', 638
execute rdt.rdtAddMsg 158363, 10, 'Must Receive        ', 'us_english', 638

-- WMS-21480
execute rdt.rdtAddMsg 158364, 10, '158364 Black List   ', 'us_english', 638
execute rdt.rdtAddMsg 158365, 10, '158365 Blank RDT UDF', 'us_english', 638
execute rdt.rdtAddMsg 158366, 10, 'Cannot Rcv NFC SKU  ', 'us_english', 638
execute rdt.rdtAddMsg 158367, 10, '158367 NFC ASN      ', 'us_english', 638
execute rdt.rdtAddMsg 158368, 10, '158368 NFC RFID ASN ', 'us_english', 638

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 158351 AND 158400

