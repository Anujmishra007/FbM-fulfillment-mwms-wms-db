--rdt_839ExtSNVal02
-- 270951 - 271000
EXECUTE rdt.rdtdropmsg 270951 , 271000

EXECUTE rdt.rdtAddMsg 270951, 10, '270951 SNOAlreadyScanned', 'us_english', 839, 0, '270951 Serial no already scanned'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 270951 AND 271000
