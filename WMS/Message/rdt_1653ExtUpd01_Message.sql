--rdt_1653ExtUpd01
execute rdt.rdtDropMsg 156451, 156500

execute rdt.rdtAddMsg 156451, 10, '56451^Insert TL2 Err',   'us_english', 1653


SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 156451 AND 156500