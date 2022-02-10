--rdt_1819ExtVal10
exec rdt.rdtDropMsg 152351 , 152400

execute rdt.rdtAddMsg 152351, 10, '52351^Mix UCC SKU',     'us_english', 1819

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 152351 AND 152400

