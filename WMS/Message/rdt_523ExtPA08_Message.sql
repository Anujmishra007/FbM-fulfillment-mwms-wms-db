--rdt_523ExtPA08
 exec rdt.rdtDropMsg 114551 , 114600

execute rdt.rdtAddMsg 114551, 10, '14551^INVALID UCCNO',    'us_english', 523
execute rdt.rdtAddMsg 114552, 10, '14552^MIX SKU UCC',      'us_english', 523
execute rdt.rdtAddMsg 114553, 10, '14553^UCCSKU X MATCH',   'us_english', 523
execute rdt.rdtAddMsg 114554, 10, '14554^MIX SKU GRADE',    'us_english', 523
execute rdt.rdtAddMsg 114555, 10, '14555^INV SKU GRADE',    'us_english', 523
execute rdt.rdtAddMsg 114556, 10, '14556^NO HOME LOC',      'us_english', 523
execute rdt.rdtAddMsg 114557, 10, '14557^NO SUGGEST LOC',   'us_english', 523

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 114551 AND 114600

