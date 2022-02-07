--rdt_1812CreateTask01
execute rdt.rdtdropmsg 123351, 123400

execute rdt.rdtAddMsg 123351, 10, '123351GetKey Fail   ', 'us_english', 1812
execute rdt.rdtAddMsg 123352, 10, '123352GetKey Fail   ', 'us_english', 1812
execute rdt.rdtAddMsg 123353, 10, '123353INSTaskDTLFail', 'us_english', 1812
execute rdt.rdtAddMsg 123354, 10, '123354INSTaskDTLFail', 'us_english', 1812
execute rdt.rdtAddMsg 123355, 10, '123355INSTaskDTLFail', 'us_english', 1812
