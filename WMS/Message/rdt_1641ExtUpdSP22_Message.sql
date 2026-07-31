-- rdt_1641ExtUpdSP22
-- FCR-13319
EXECUTE rdt.rdtDropMsg 271451, 271500

EXECUTE rdt.rdtAddMsg 271451, 10, '271451^UpdDropIDDetailFail',   'us_english', 1641, 0, '271451 Fail to update DropIDDetail'
EXECUTE rdt.rdtAddMsg 271452, 10, '271452^InsDropIDDetailFail',   'us_english', 1641, 0, '271452 Fail to insert data into DropIDDetail'
EXECUTE rdt.rdtAddMsg 271453, 10, '271453^UpdDropIDDetailFail',   'us_english', 1641, 0, '271453 Fail to update DropIDDetail'
EXECUTE rdt.rdtAddMsg 271454, 10, '271454^InsDropIDDetailFail',   'us_english', 1641, 0, '271454 Fail to insert data into DropIDDetail'
EXECUTE rdt.rdtAddMsg 271455, 10, '271455^DelDropIDDetailFail',   'us_english', 1641, 0, '271455 Fail to delete DropIDDetail'
EXECUTE rdt.rdtAddMsg 271456, 10, '271456^InsDropIDDetailFail',   'us_english', 1641, 0, '271456 Fail to insert data into DropIDDetail'
EXECUTE rdt.rdtAddMsg 271457, 10, '271457^InsDropIDDetailFail',   'us_english', 1641, 0, '271457 Fail to insert data into DropIDDetail'
EXECUTE rdt.rdtAddMsg 271458, 10, '271458^InvScannedUCC',         'us_english', 1641, 0, '271458 Invalid scanned UCC, no matching data is found'
EXECUTE rdt.rdtAddMsg 271459, 10, '271459^UpdOrderFail',          'us_english', 1641, 0, '271459 Fail to update ORDERS with DropID'
EXECUTE rdt.rdtAddMsg 271460, 10, '271460^UpdOrderFail',          'us_english', 1641, 0, '271460 Fail to update ORDERS with DropID'
EXECUTE rdt.rdtAddMsg 271461, 10, '271461^UpdOrderFail',          'us_english', 1641, 0, '271461 Fail to update ORDERS with DropID'
EXECUTE rdt.rdtAddMsg 271462, 10, '271462^UpdOrderFail',          'us_english', 1641, 0, '271462 Fail to update ORDERS with DropID'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 271451 AND 271500 ORDER BY Message_ID
