--rdt_TM_Replen_ClosePallet
execute rdt.rdtdropmsg 78501, 78550

execute rdt.rdtAddMsg 78501, 10, '78501^Upd LLI Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 78502, 10, '78502^Upd LLI Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 78503, 10, '78503^UpdRPLogFail  ', 'us_english', 1764
execute rdt.rdtAddMsg 78504, 10, '78504^UpdTaskdetFail', 'us_english', 1764
execute rdt.rdtAddMsg 78505, 10, '78505^DelRPFLogFail ', 'us_english', 1764
execute rdt.rdtAddMsg 78506, 10, '78506^LockOrderFail ', 'us_english', 1764

--WMS-15656
execute rdt.rdtAddMsg 78507, 10, '78507^No RP1 created ', 'us_english', 1764
execute rdt.rdtAddMsg 78508, 10, '78508^UPD UCC Fail   ', 'us_english', 1764
