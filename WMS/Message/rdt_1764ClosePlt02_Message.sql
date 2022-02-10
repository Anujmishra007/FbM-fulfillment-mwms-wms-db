--rdt_1764ClosePlt02
execute rdt.rdtdropmsg 167701, 167750

execute rdt.rdtAddMsg 167701, 10, '167701Upd LLI Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 167702, 10, '167702Upd LLI Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 167703, 10, '167703UpdRPLogFail  ', 'us_english', 1764
execute rdt.rdtAddMsg 167704, 10, '167704UpdTaskdetFail', 'us_english', 1764
execute rdt.rdtAddMsg 167705, 10, '167705DelRPFLogFail ', 'us_english', 1764
execute rdt.rdtAddMsg 167706, 10, '167706LockOrderFail ', 'us_english', 1764
execute rdt.rdtAddMsg 167707, 10, '167707No RP1 created', 'us_english', 1764
execute rdt.rdtAddMsg 167708, 10, '167708UPD UCC Fail  ', 'us_english', 1764

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 167701 AND 167750