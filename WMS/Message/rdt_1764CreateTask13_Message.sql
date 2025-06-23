-- rdt_1764CreateTask13
--230101 - 230150
execute rdt.rdtdropmsg 230101, 230150

--execute rdt.rdtAddMsg 230101, 10, '230101NoTasks', 'us_english', 1764, 0, '230101 No Task to Handle'
execute rdt.rdtAddMsg 230102, 10, '230102GetTaskKeyFail', 'us_english', 1764, 0, '230102 TaskKey Generation Failure'
execute rdt.rdtAddMsg 230103, 10, '230103GetTaskKeyFail', 'us_english', 1764, 0, '230103 TaskKey Generation Failure'
execute rdt.rdtAddMsg 230104, 10, '230104GenNewTaskFail', 'us_english', 1764, 0, '230104 Fail to Insert Task'


select * from rdt.rdtmsg where message_id between 230101 and 230150