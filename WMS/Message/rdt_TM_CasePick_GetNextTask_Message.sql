--rdt_TM_CasePick_GetNextTask
--execute rdt.rdtdropmsg 51301, 51350

execute rdt.rdtAddMsg 51301, 10, '51301^NoTask.ClosePL', 'us_english', 1812
execute rdt.rdtAddMsg 51302, 10, '51302^No more task',   'us_english', 1812
execute rdt.rdtAddMsg 51303, 10, '51303^UpdTaskDtlFail', 'us_english', 1812
