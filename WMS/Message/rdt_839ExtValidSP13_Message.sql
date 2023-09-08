--rdt_839ExtValidSP13
exec rdt.rdtdropmsg 203751 , 203800

execute rdt.rdtAddMsg 203751, 10, '203751Invalid Format', 'us_english', 839
execute rdt.rdtAddMsg 203752, 10, '203752 DropID Exists', 'us_english', 839

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 203751 AND 203800
