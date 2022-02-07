--rdt_1748GetTask01
execute rdt.rdtdropmsg 54451, 54500

execute rdt.rdtAddMsg 54451, 10, '54451^NoTask.ClosePL', 'us_english', 1748
execute rdt.rdtAddMsg 54452, 10, '54452^No more task',   'us_english', 1748
execute rdt.rdtAddMsg 54453, 10, '54453^UpdTaskDtlFail', 'us_english', 1748
