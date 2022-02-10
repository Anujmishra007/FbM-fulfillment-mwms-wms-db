--rdt_1653ExtUpd02
execute rdt.rdtDropMsg 173051 , 173100

execute rdt.rdtAddMsg 173051, 10, '173051Insert TL2 Err',   'us_english', 1653

--WMS-18115
execute rdt.rdtAddMsg 173052, 10, '173052 DelEcomLogErr',   'us_english', 1653


SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 173051 AND 173100