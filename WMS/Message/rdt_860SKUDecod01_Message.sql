--rdt_860SKUDecod01
exec rdt.rdtDropMsg 123651 , 123700

execute rdt.rdtAddMsg 123651, 10, '22051^Inv Serial No',   'us_english', 860


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 123651 AND 123700
