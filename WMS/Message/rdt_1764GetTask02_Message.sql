--rdt_1764GetTask02
execute rdt.rdtdropmsg 110801, 110850

execute rdt.rdtAddMsg 110801, 10, '110801Exceed Max Ctn', 'us_english', 1764
execute rdt.rdtAddMsg 110802, 10, '110802NoTask.ClosePL', 'us_english', 1764
execute rdt.rdtAddMsg 110803, 10, '110803No more task  ', 'us_english', 1764
execute rdt.rdtAddMsg 110804, 10, '110804UpdTaskDtlFail', 'us_english', 1764
