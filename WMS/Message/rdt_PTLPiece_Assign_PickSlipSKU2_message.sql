-- rdt_PTLPiece_Assign_PickSlipSKU2
exec rdt.rdtDropMsg 207001, 207050

execute rdt.rdtAddMsg 207001, 10, '207001Need PickSlipN', 'us_english', 803
execute rdt.rdtAddMsg 207002, 10, '207002Batch assigned', 'us_english', 803
execute rdt.rdtAddMsg 207003, 10, '207003Invalid PSNO  ', 'us_english', 803
execute rdt.rdtAddMsg 207004, 10, '207004Bad OrderKey  ', 'us_english', 803
execute rdt.rdtAddMsg 207005, 10, '207005Diff storer   ', 'us_english', 803
execute rdt.rdtAddMsg 207006, 10, '207006Diff facility ', 'us_english', 803
execute rdt.rdtAddMsg 207007, 10, '207007Order CANCEL  ', 'us_english', 803
execute rdt.rdtAddMsg 207008, 10, '207008Invalid PSNO  ', 'us_english', 803
execute rdt.rdtAddMsg 207009, 10, '207009Invalid PSNO  ', 'us_english', 803
execute rdt.rdtAddMsg 207010, 10, '207010Not enuf Pos  ', 'us_english', 803
execute rdt.rdtAddMsg 207011, 10, '207011INS Log fail  ', 'us_english', 803
