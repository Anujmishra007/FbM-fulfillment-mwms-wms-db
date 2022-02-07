--rdt_TM_Move_GetNextTask
execute rdt.rdtdropmsg 87601, 87650

execute rdt.rdtAddMsg '87601', 10, '87601^NoTask.ClosePL', 'us_english', 1748
execute rdt.rdtAddMsg '87602', 10, '87602^No more task  ', 'us_english', 1748
execute rdt.rdtAddMsg '87603', 10, '87603^UpdTaskDtlFail', 'us_english', 1748
