--nspTTMEvaluateFPKTasks
execute rdt.rdtdropmsg 90701, 90750

execute rdt.rdtAddMsg 90701, 10, '90701 FPK Code Fail ', 'us_english', 1770
execute rdt.rdtAddMsg 90702, 10, '90702 OpenCursorFail', 'us_english', 1770
execute rdt.rdtAddMsg 90703, 10, '90703 UPDTaskDtlFail', 'us_english', 1770
