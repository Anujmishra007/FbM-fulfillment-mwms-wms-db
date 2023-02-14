--rdt_573ExtUpdSP07
execute rdt.rdtDropMsg 194151 , 194200

execute rdt.rdtAddMsg 194151, 10, '194151UpdSortCodeErr',  'us_english', 573

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 194151 AND 194200