-- rdt_1812DecodeSP03
--239701 - 239750

execute rdt.rdtDropMsg 239701 , 239750

execute rdt.rdtAddMsg 239701, 10, '239701InvalidInputValue',    'us_english', 1812, 0, '239701: Invalid input value'
execute rdt.rdtAddMsg 239702, 10, '239702InvalidInputValue',    'us_english', 1812, 0, '239702: Invalid input value'
execute rdt.rdtAddMsg 239703, 10, '239703MissingSKU',           'us_english', 1812, 0, '239703: Task miss SKU'
execute rdt.rdtAddMsg 239704, 10, '239704MissingQty',           'us_english', 1812, 0, '239704: Task Qty is 0'


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 239701 AND 239750

