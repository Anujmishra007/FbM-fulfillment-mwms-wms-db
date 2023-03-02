--rdt_1666ExtValid07
rdt.rdtDropMsg 196851 ,196900	

execute rdt.rdtAddMsg 196851, 10, '196851No Dest Ctry    ',    'us_english', 1666
execute rdt.rdtAddMsg 196852, 10, '196852PlDt Not Close  ',    'us_english', 1666
execute rdt.rdtAddMsg 196853, 10, '196853Orders Shipped  ',    'us_english', 1666
execute rdt.rdtAddMsg 196854, 10, '196854WrongCourier    ',    'us_english', 1666
execute rdt.rdtAddMsg 196855, 10, '196855Wrong Country   ',    'us_english', 1666


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 196851 AND 196900