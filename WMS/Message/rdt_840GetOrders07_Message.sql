--rdt_840GetOrders07
exec rdt.rdtDropMsg 180751 , 180800

execute rdt.rdtAddMsg 180751, 10, '180751 No Orders    ',   'us_english', 840
execute rdt.rdtAddMsg 180752, 10, '180752 Not Sorted   ',   'us_english', 840

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 180751 AND 180800


