--rdt_1764ClosePlt07
--FCR-12990

EXECUTE rdt.rdtdropmsg 270051, 270100

EXECUTE rdt.rdtAddMsg 270051, 10, '270051^Upd LLI Fail  ', 'us_english', 1764, 0, '270051 Update LOTXLOCXID fail'
EXECUTE rdt.rdtAddMsg 270052, 10, '270052^UpdTaskdetFail', 'us_english', 1764, 0, '270052 Update TaskDetail fail'
EXECUTE rdt.rdtAddMsg 270053, 10, '270053^DelRPFLogFail ', 'us_english', 1764, 0, '270053 Delete rdtRPFLog fail'
EXECUTE rdt.rdtAddMsg 270054, 10, '270054^LockOrderFail ', 'us_english', 1764, 0, '270054 Lock order fail'

EXECUTE rdt.rdtAddMsg 270055, 10, '270055^UPD UCC Fail   ', 'us_english', 1764, 0, '270055 Update UCC fail'
EXECUTE rdt.rdtAddMsg 270056, 10, '270056^UPD PKD Fail   ', 'us_english', 1764, 0, '270056 Update PickDetail fail'
EXECUTE rdt.rdtAddMsg 270057, 10, '270057^UPD PKD Fail   ', 'us_english', 1764, 0, '270057 Update FCP PickDetail.Loc as PND fail'

SELECT * FROM rdt.rdtmsg WITH (NOLOCK) WHERE message_id BETWEEN 270051 AND 270100