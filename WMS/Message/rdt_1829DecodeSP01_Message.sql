--rdt_1829DecodeSP01
exec rdt.rdtDropMsg 135101 , 135150

execute rdt.rdtAddMsg 135101, 10, '35101^Invalid SKU',      'us_english', 1829
execute rdt.rdtAddMsg 135102, 10, '35102^MultiSKUBarcod',   'us_english', 1829

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 135101 AND 135150