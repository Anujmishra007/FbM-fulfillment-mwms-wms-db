--rdt_1666ExtValid04
rdt.rdtDropMsg 169351 , 169400	

execute rdt.rdtAddMsg 169351, 10, '169351 No Dest Ctry',    'us_english', 1666
execute rdt.rdtAddMsg 169352, 10, '169352 PLT Not Close',   'us_english', 1666
execute rdt.rdtAddMsg 169353, 10, '169353Orders Shipped',   'us_english', 1666
execute rdt.rdtAddMsg 169354, 10, '169354Pallet Scanned',   'us_english', 1666
execute rdt.rdtAddMsg 169355, 10, 'Wrong Country/',         'us_english', 1666
execute rdt.rdtAddMsg 169356, 10, 'Marketplace/',           'us_english', 1666
execute rdt.rdtAddMsg 169357, 10, 'Carrier/',               'us_english', 1666

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 169351 AND 169400