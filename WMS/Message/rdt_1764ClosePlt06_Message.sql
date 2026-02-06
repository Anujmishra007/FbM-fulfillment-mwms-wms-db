--rdt_1764ClosePlt07
-- FCR-10467
execute rdt.rdtdropmsg 257651, 257700

execute rdt.rdtAddMsg 257651, 10, '257651^Upd LLI Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 257652, 10, '257652^Upd LLI Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 257653, 10, '257653^UpdRPLogFail  ', 'us_english', 1764
execute rdt.rdtAddMsg 257654, 10, '257654^UpdTaskdetFail', 'us_english', 1764
execute rdt.rdtAddMsg 257655, 10, '257655^DelRPFLogFail ', 'us_english', 1764
execute rdt.rdtAddMsg 257656, 10, '257656^LockOrderFail ', 'us_english', 1764

execute rdt.rdtAddMsg 257657, 10, '257657^No RP1 created ', 'us_english', 1764
execute rdt.rdtAddMsg 257658, 10, '257658^UPD UCC Fail   ', 'us_english', 1764
execute rdt.rdtAddMsg 257659, 10, '257659^CallSPFail   ',   'us_english', 1764, 0, '257659 Exec rdt_Putaway_PendingMoveIn failed'
execute rdt.rdtAddMsg 257660, 10, '257660^CallSPFail   ',   'us_english', 1764, 0, '257660 Exec rdt_Putaway_PendingMoveIn failed'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 257651 AND 257700