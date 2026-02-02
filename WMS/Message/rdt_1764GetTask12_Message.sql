--rdt_1764GetTask12
--230301 - 230350
execute rdt.rdtdropmsg 230301, 230350

execute rdt.rdtAddMsg '230301', 10, '230301^NoTask.ClosePL', 'us_english', 1764, 0, '230301 No task. Close pallet'
execute rdt.rdtAddMsg '230302', 10, '230302^No more task',   'us_english', 1764, 0, '230302 No more task'
execute rdt.rdtAddMsg '230303', 10, '230303^UpdTaskDtlFail', 'us_english', 1764, 0, '230303 Update TaskDetail fail'

--UWP-34684
execute rdt.rdtAddMsg '230304', 10, '230304^NoFinalLoc',     'us_english', 1764, 0, '230304 No Final Loc'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 230301 AND 230350