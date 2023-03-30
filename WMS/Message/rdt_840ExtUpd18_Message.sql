--rdt_840ExtUpd18
exec rdt.rdtDropMsg 179051 , 179100

execute rdt.rdtAddMsg 179051, 10, '179051 1 Order 1 Ctn',   'us_english', 840
execute rdt.rdtAddMsg 179052, 10, '179052 Over Weight  ',   'us_english', 840
execute rdt.rdtAddMsg 179053, 10, '179053 Heavy Box    ',   'us_english', 840
execute rdt.rdtAddMsg 179054, 10, '179054 UpdQtyMovedEr',   'us_english', 840

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 179051 AND 179100


