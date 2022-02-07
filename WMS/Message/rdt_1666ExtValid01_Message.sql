--rdt_1666ExtValid01
rdt.rdtDropMsg 141601 , 141650	

execute rdt.rdtAddMsg 141601, 10, '41601^No Dest Ctry',     'us_english', 1666
execute rdt.rdtAddMsg 141602, 10, '41602^PlDt Not Close',   'us_english', 1666
execute rdt.rdtAddMsg 141603, 10, '41603^Orders Shipped',   'us_english', 1666
execute rdt.rdtAddMsg 141604, 10, '41604^Pallet Scanned',   'us_english', 1666
execute rdt.rdtAddMsg 141605, 10, '41605^Wrong Country',    'us_english', 1666
execute rdt.rdtAddMsg 141606, 10, '141606WrongCourier',    'us_english', 1666

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 141601 AND 141650