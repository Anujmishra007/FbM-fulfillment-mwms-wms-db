--rdt_PTLStation_CreateTask_ToteIDSKU08
execute rdt.rdtdropmsg 222701 , 222750

execute rdt.rdtAddMsg 222701, 10, '222701AssignCartonID',    'us_english',805
execute rdt.rdtAddMsg 222702, 10, '222702No task','us_english',805
execute rdt.rdtAddMsg 222703, 10, '222703INSPTLTranFail','us_english',805
execute rdt.rdtAddMsg 222704, 10, '222704DropIDInUsed','us_english',805



