-- rdt_PTLStation_CreateTask_ToteIDSKU07
execute rdt.rdtDropMsg 172951, 173000		

execute rdt.rdtAddMsg 172951, 10, '172951AssignCartonID', 'us_english', 805
execute rdt.rdtAddMsg 172952, 10, '172952NoTask','us_english', 805
execute rdt.rdtAddMsg 172953, 10, '172953INSPTLTranFail', 'us_english', 805
