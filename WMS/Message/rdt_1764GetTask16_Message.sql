--rdt_1764GetTask16
--FCR-14963

EXECUTE rdt.rdtdropmsg 276201, 276250

EXECUTE rdt.rdtAddMsg 276201, 10, '276201GrpKeyEmpty',            'us_english', 1764, 0, '276201 Groupkey is empty'
EXECUTE rdt.rdtAddMsg 276202, 10, '276202NoMoreTask',             'us_english', 1764, 0, '276202 No more task'
EXECUTE rdt.rdtAddMsg 276203, 10, '276203LockTskFail',            'us_english', 1764, 0, '276203 Fail to lock task'

SELECT * FROM rdt.rdtMsg WHERE Message_ID BETWEEN 276201 AND 276250