--rdt_1812GetTask01
execute rdt.rdtdropmsg 51101, 51150

execute rdt.rdtAddMsg 51101, 10, '51101^NoTask.ClosePL', 'us_english', 1812
execute rdt.rdtAddMsg 51102, 10, '51102^No more task  ', 'us_english', 1812
execute rdt.rdtAddMsg 51103, 10, '51103^UpdTaskDtlFail', 'us_english', 1812
