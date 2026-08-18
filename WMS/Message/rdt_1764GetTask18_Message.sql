--rdt_1764GetTask18

EXECUTE rdt.rdtdropmsg 276801, 276850

EXECUTE rdt.rdtAddMsg 276801, 10, '276801^Exceed Max Ctn', 'us_english', 1764, 0, '276801 Exceed max cartons'
EXECUTE rdt.rdtAddMsg 276802, 10, '276802^NoTask.ClosePL', 'us_english', 1764, 0, '276802 No task, close pallet list'
EXECUTE rdt.rdtAddMsg 276803, 10, '276803^No more task  ', 'us_english', 1764, 0, '276803 No more task'
EXECUTE rdt.rdtAddMsg 276804, 10, '276804^UpdTaskDtlFail', 'us_english', 1764, 0, '276804 Update task detail failed'
EXECUTE rdt.rdtAddMsg 276805, 10, '276805^Loc type!= PND', 'us_english', 1764, 0, '276805 Location type is not PND'

SELECT * FROM rdt.rdtmsg WITH (NOLOCK) WHERE Message_ID BETWEEN 276801 AND 276850
