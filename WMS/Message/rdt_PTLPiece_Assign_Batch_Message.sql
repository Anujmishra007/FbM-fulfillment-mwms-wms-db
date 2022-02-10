-- rdt_PTLPiece_Assign_Batch
execute rdt.rdtDropMsg 99701, 99750

execute rdt.rdtAddMsg 99701, 10, '99701^Diff batch    ', 'us_english', 803
execute rdt.rdtAddMsg 99702, 10, '99702^Invalid batch ', 'us_english', 803
execute rdt.rdtAddMsg 99703, 10, '99703^Batch assigned', 'us_english', 803
execute rdt.rdtAddMsg 99704, 10, '99704^Diff Storerf  ', 'us_english', 803
execute rdt.rdtAddMsg 99705, 10, '99705^Pick NotFinish', 'us_english', 803
execute rdt.rdtAddMsg 99706, 10, '99706^Not enuf Pos  ', 'us_english', 803
execute rdt.rdtAddMsg 99707, 10, '99707^INS Log fail  ', 'us_english', 803
