--rdt_TM_Replen_GetNextTask
--execute rdt.rdtdropmsg 74351, 74400

execute rdt.rdtAddMsg '74351', 10, '74351^NoTask.ClosePL', 'us_english', 1764
execute rdt.rdtAddMsg '74352', 10, '74352^No more task',   'us_english', 1764
execute rdt.rdtAddMsg '74353', 10, '74353^UpdTaskDtlFail', 'us_english', 1764
execute rdt.rdtAddMsg '74354', 10, '74354^InsRPLogFail',   'us_english', 1764
