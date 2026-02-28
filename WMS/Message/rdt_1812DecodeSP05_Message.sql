-- rdt_1812DecodeSP05
-- UWP-47565
execute rdt.rdtDropMsg 257101 , 257150

execute rdt.rdtAddMsg 257101, 10, '257101 Invalid UCCNo',    'us_english', 1812
execute rdt.rdtAddMsg 257102, 10, '257102 Invalid UCCNo',    'us_english', 1812
execute rdt.rdtAddMsg 257103, 10, '257103 Invalid SKU  ',    'us_english', 1812
execute rdt.rdtAddMsg 257104, 10, '257104 Invalid Qty  ',    'us_english', 1812

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 257101 AND 257150

