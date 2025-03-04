-- rdt_1812ExtScn05
execute rdt.rdtDropMsg 228951 , 229000

execute rdt.rdtAddMsg 228951, 10, '228951 Need Lane    ',    'us_english', 1812
execute rdt.rdtAddMsg 228952, 10, '228952 Mix Shipper  ',    'us_english', 1812
execute rdt.rdtAddMsg 228953, 10, '228953 Mix Shipper  ',    'us_english', 1812
execute rdt.rdtAddMsg 228954, 10, '228954 Diff Lane    ',    'us_english', 1812
execute rdt.rdtAddMsg 228955, 10, '228955 No Split Lane',    'us_english', 1812

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 228951 AND 229000

