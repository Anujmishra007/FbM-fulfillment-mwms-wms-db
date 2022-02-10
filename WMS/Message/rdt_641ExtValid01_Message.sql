-- rdt_641ExtValid01
execute rdt.rdtDropMsg 149451, 149500

execute rdt.rdtAddMsg 149451, 10, '49451^CANNOT MIX SKU', 'us_english', 641
execute rdt.rdtAddMsg 149452, 10, '49452^Over Scanned',   'us_english', 641

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 149451 AND 149500