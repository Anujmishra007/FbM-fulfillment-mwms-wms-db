--rdt_1836ExtUpd07
--FCR-8535
--253301 - 253350

EXEC rdt.rdtdropmsg 253301 , 253350	


EXECUTE rdt.rdtAddMsg 253301, 10, '253301^UpdUCCFail',      'us_english', 1836, 0, '253301 Update UCC failed'
-- FCR-10467
EXECUTE rdt.rdtAddMsg 253302, 10, '253302^UpdTaskFail',     'us_english', 1836, 0, '253302 Update TaskDetail failed'
EXECUTE rdt.rdtAddMsg 253303, 10, '253303^ExecSPFail',      'us_english', 1836, 0, '253303 Exec rdt_Putaway_PendingMoveIn failed'
EXECUTE rdt.rdtAddMsg 253304, 10, '253304^ExecSPFail',      'us_english', 1836, 0, '253304 Exec rdt_Putaway_PendingMoveIn failed'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 253301 AND 253350