-- rdt_PTLStation_CreateTask_WaveCriteria
execute rdt.rdtDropMsg 98051, 98100

execute rdt.rdtAddMsg 98051, 10, '98051^AssignCartonID', 'us_english', 805
execute rdt.rdtAddMsg 98052, 10, '98052^INSPTLTranFail', 'us_english', 805
execute rdt.rdtAddMsg 98053, 10, '98053^No more task  ', 'us_english', 805
execute rdt.rdtAddMsg 98054, 10, '98054^No Task (PTL) ', 'us_english', 805
