--rdt_599ExtUpd03
--FCR-8280
EXECUTE rdt.rdtDropMsg 248951, 249000

EXECUTE rdt.rdtAddMsg 248951, 10, '248951 DelRctSNFail',    'us_english', 599, 0, '248951 Delete ReceiptSerialNo Failed'
EXECUTE rdt.rdtAddMsg 248952, 10, '248952 DelSNFail',       'us_english', 599, 0, '248952 Delete SerialNo Failed'
EXECUTE rdt.rdtAddMsg 248953, 10, '248953 UpdASNDtlFail',   'us_english', 599, 0, '248953 Update  Receipt Detail Failed'

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE Message_ID BETWEEN 248951 AND 249000