--rdt_1836ExtUpd03
exec rdt.rdtdropmsg 170201, 170250

execute rdt.rdtAddMsg 170201, 10, '170201UpdPickdetFail', 'us_english', 1836
execute rdt.rdtAddMsg 170202, 10, '170202UpdPickdetFail', 'us_english', 1836
execute rdt.rdtAddMsg 170203, 10, '170203UpdTaskdetFail', 'us_english', 1836


SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 170201 AND 170250


