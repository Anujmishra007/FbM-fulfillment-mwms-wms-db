--rdt_1764ClosePlt04
execute rdt.rdtdropmsg 248401, 248450

--FCR-7730
execute rdt.rdtAddMsg 248401, 10, '248401 UpdTskFail',    'us_english', 1764, 0, '248401 Update TaskDetail ToLoc Fail'

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 248401 AND 248450