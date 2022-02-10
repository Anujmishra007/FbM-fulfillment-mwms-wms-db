--rdt_1764ClosePlt01
execute rdt.rdtdropmsg 166301, 166350

execute rdt.rdtAddMsg 166301, 10, '166301Upd LLI Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 166302, 10, '166302Upd LLI Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 166303, 10, '166303UpdRPLogFail  ', 'us_english', 1764
execute rdt.rdtAddMsg 166304, 10, '166304UpdTaskdetFail', 'us_english', 1764
execute rdt.rdtAddMsg 166305, 10, '166305DelRPFLogFail ', 'us_english', 1764
execute rdt.rdtAddMsg 166306, 10, '166306LockOrderFail ', 'us_english', 1764
execute rdt.rdtAddMsg 166307, 10, '166307No RP1 created', 'us_english', 1764
execute rdt.rdtAddMsg 166308, 10, '166308UPD UCC Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 166309, 10, '166309Offset Error  ', 'us_english', 1764

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 166301 AND 166350