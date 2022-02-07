-- rdt_SortAndPack_Consignee_GetTask
exec rdt.rdtDropMsg 161101 , 161150

execute rdt.rdtAddMsg 161101, 10, '161101 Invalid SKU', 'us_english', 1851
execute rdt.rdtAddMsg 161102, 10, '161102 Invalid SKU', 'us_english', 1851
execute rdt.rdtAddMsg 161103, 10, '161103 Invalid UCC', 'us_english', 1851
execute rdt.rdtAddMsg 161104, 10, '161104 UCC >1 SKU ', 'us_english', 1851


SELECT TOP 100 * FROM rdt.rdtMsg (NOLOCK) WHERE message_id BETWEEN 161101 and 161150



