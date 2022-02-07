--rdt_727Inquiry10
exec rdt.rdtdropmsg 175151, 175200

execute rdt.rdtAddMsg 175151, 10, '175151 SKU Required ', 'us_english', 727
execute rdt.rdtAddMsg 175152, 10, '175152 Invalid SKU  ', 'us_english', 727
execute rdt.rdtAddMsg 175153, 10, '175153 MultiSKUBarco', 'us_english', 727

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 175151 AND 175200