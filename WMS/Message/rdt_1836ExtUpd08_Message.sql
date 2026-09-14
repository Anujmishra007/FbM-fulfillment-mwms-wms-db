--rdt_1836ExtUpd08
--FCR-7820
--270001 - 270050

EXEC rdt.rdtdropmsg 270001 , 270050

EXECUTE rdt.rdtAddMsg 270001, 10, '270001^TaskUpdateFail',     'us_english', 1836, 0, '270001 Update TaskDetail failed'
EXECUTE rdt.rdtAddMsg 270002, 10, '270002^DelRFPutawayFail',   'us_english', 1836, 0, '270002 Delete RFPutaway failed'
EXECUTE rdt.rdtAddMsg 270003, 10, '270003^DelRFPutawayFail',   'us_english', 1836, 0, '270003 Delete RFPutaway failed'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 270001 AND 270050
