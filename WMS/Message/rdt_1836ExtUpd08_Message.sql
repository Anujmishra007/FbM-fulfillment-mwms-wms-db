--rdt_1836ExtUpd08
--FCR-7820
--270001 - 270050

EXEC rdt.rdtdropmsg 270001 , 270050

EXECUTE rdt.rdtAddMsg 270001, 10, '270001^TaskUpdateFail', 'us_english', 1836, 0, '270001 Update TaskDetail failed'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 270001 AND 270050
