--rdt_1812GetTask09
-- FCR-10467
execute rdt.rdtdropmsg 258501, 258550

execute rdt.rdtAddMsg 258501, 10, '258501^NoTask.ClosePL', 'us_english', 1812, 0, '258501 Groupkey complete! CLOSE PALLET to continue'
execute rdt.rdtAddMsg 258502, 10, '258502^No more task  ', 'us_english', 1812, 0, '258502 No more task'
execute rdt.rdtAddMsg 258503, 10, '258503^UpdTaskDtlFail', 'us_english', 1812, 0, '258503 Update TaskDetail failed'
execute rdt.rdtAddMsg 258504, 10, '258504^UpdTaskDtlFail', 'us_english', 1812, 0, '258504 Update TaskDetail failed'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 258501 AND 258550