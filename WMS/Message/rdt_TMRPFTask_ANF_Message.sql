--rdt_TMRPFTask_ANF
execute rdt.rdtdropmsg 90151, 90200

execute rdt.rdtAddMsg '90151', 10, '90151^Exceed Max Ctn', 'us_english', 1764
execute rdt.rdtAddMsg '90152', 10, '90152^NoTask.ClosePL', 'us_english', 1764
execute rdt.rdtAddMsg '90153', 10, '90153^No more task  ', 'us_english', 1764
execute rdt.rdtAddMsg '90154', 10, '90154^UpdTaskDtlFail', 'us_english', 1764
