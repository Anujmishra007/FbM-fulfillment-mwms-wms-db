--rdt_638CaptureRDtl01
rdt.rdtDropMsg 167351 , 167400	

execute rdt.rdtAddMsg 167351, 10, '167351GIFT SKU REQ',  'us_english', 638
execute rdt.rdtAddMsg 167352, 10, '167352INV GIFT SKU',  'us_english', 638
execute rdt.rdtAddMsg 167353, 10, '167353INV GRADE',     'us_english', 638

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 167351 AND 167400