-- rdt_1812DecodeSP02
execute rdt.rdtDropMsg 223651 , 223700

execute rdt.rdtAddMsg 223651, 10, '223651 Invalid UCCNo',    'us_english', 1812
execute rdt.rdtAddMsg 223652, 10, '223652 Invalid UCCNo',    'us_english', 1812
execute rdt.rdtAddMsg 223653, 10, '223653 Invalid SKU  ',    'us_english', 1812
execute rdt.rdtAddMsg 223654, 10, '223654 Invalid Qty  ',    'us_english', 1812

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 223651 AND 223700

