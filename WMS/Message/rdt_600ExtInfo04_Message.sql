--rdt_600ExtInfo04
exec rdt.rdtDropMsg 176451,176500

execute rdt.rdtAddMsg 176451, 10, '176451InvProdDate', 'us_english', 855
execute rdt.rdtAddMsg 176452, 10, '176452SKU>SSD    ', 'us_english', 855


SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 176451 AND  176500

