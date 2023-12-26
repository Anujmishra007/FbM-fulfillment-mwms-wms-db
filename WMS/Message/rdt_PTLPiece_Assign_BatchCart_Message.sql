-- rdt_PTLPiece_Assign_BatchCart
execute rdt.rdtDropMsg 208001, 208050

execute rdt.rdtAddMsg 208001, 10, '208001Need batch    ', 'us_english', 803
execute rdt.rdtAddMsg 208002, 10, '208002Invalid batch ', 'us_english', 803
execute rdt.rdtAddMsg 208003, 10, '208003Batch assigned', 'us_english', 803
execute rdt.rdtAddMsg 208004, 10, '208004Diff Storerf  ', 'us_english', 803
execute rdt.rdtAddMsg 208005, 10, '208005Pick NotFinish', 'us_english', 803
execute rdt.rdtAddMsg 208006, 10, '208006Need cart     ', 'us_english', 803
execute rdt.rdtAddMsg 208007, 10, '208007Invalid cart  ', 'us_english', 803
execute rdt.rdtAddMsg 208008, 10, '208008Cart assigned ', 'us_english', 803
execute rdt.rdtAddMsg 208009, 10, '208009Not enuf Pos  ', 'us_english', 803
execute rdt.rdtAddMsg 208010, 10, '208010INS Log fail  ', 'us_english', 803
