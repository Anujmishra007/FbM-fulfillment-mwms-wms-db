--rdt_1764ClosePlt04
execute rdt.rdtdropmsg 248401, 248450

--FCR-7730
execute rdt.rdtAddMsg 248401, 10, '248401 UpdTskFail',    'us_english', 1764, 0, '248401 Update TaskDetail ToLoc Failed'

--UWP-43847
execute rdt.rdtAddMsg 248402, 10, '248402 UpdPKDFail',    'us_english', 1764, 0, '248402 Update PickDetail Failed'
execute rdt.rdtAddMsg 248403, 10, '248403 UpdTskFail',    'us_english', 1764, 0, '248403 Print ZPL Failed'

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 248401 AND 248450