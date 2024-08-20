--rdt_1768ExtSNVal01
exec rdt.rdtDropMsg 220351 , 220400

execute rdt.rdtAddMsg 220351, 10, '220351 SNO Diff SKU ',   'us_english', 1768
execute rdt.rdtAddMsg 220352, 10, '220352 SNO ady rcv  ',   'us_english', 1768


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 220351 AND 220400


