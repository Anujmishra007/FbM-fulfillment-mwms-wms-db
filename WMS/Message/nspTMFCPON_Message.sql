--nspTMFCPON
--FCR-10467
execute rdt.rdtdropmsg 257701, 257750

execute rdt.rdtAddMsg 257701, 10, '257701 MultTskDtl',       'us_english', 1812, 0, '257701 Multiple TaskDetails are found'
execute rdt.rdtAddMsg 257702, 10, '257702 UpdTaskDtlFail',   'us_english', 1812, 0, '257702 Update TaskDetail Failed'
execute rdt.rdtAddMsg 257703, 10, '257703 MultTskDtl',       'us_english', 1812, 0, '257703 Multiple TaskDetails are found'
execute rdt.rdtAddMsg 257704, 10, '257704 UpdTaskDtlFail',   'us_english', 1812, 0, '257704 Update TaskDetail Failed'
execute rdt.rdtAddMsg 257705, 10, '257705 UpdTaskDtlFail',   'us_english', 1812, 0, '257705 Update TaskDetail Failed'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 257701 AND 257750