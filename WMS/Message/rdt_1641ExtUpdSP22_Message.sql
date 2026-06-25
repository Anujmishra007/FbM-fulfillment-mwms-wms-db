-- rdt_1641ExtUpdSP22
-- FCR-13319
EXECUTE rdt.rdtDropMsg 271451, 271500

EXECUTE rdt.rdtAddMsg 271451, 10, '271451^DelDropIDDetailFail',   'us_english', 1641, 0, '271451 Fail to delete DropIDDetail'
EXECUTE rdt.rdtAddMsg 271452, 10, '271452^InsDropIDDetailFail',   'us_english', 1641, 0, '271452 Fail to insert data into DropIDDetail'
EXECUTE rdt.rdtAddMsg 271453, 10, '271453^InsDropIDDetailFail',   'us_english', 1641, 0, '271453 Fail to insert data into DropIDDetail'
EXECUTE rdt.rdtAddMsg 271454, 10, '271454^InvScannedUCC',         'us_english', 1641, 0, '271454 Invalid scanned UCC, no matching data is found'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 271451 AND 271500 ORDER BY Message_ID