--rdt_523ExtValidSP09
exec rdt.rdtDropMsg 152451 , 152500

execute rdt.rdtAddMsg 152451, 10, '52451^UCC MIX SKU',     'us_english', 523
execute rdt.rdtAddMsg 152452, 10, '52452^UCC MIX LOTs',    'us_english', 523

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 152451 AND 152500