--rdt_PTLPiece_Assign_DropID01
execute rdt.rdtDropMsg 158551, 158600

execute rdt.rdtAddMsg 158551, 10, '158551Need DropID   ', 'us_english', 803
execute rdt.rdtAddMsg 158552, 10, '158552Bad DropID    ', 'us_english', 803
execute rdt.rdtAddMsg 158553, 10, '158553DropIDAssigned', 'us_english', 803
execute rdt.rdtAddMsg 158554, 10, '158554Not enuf Pos  ', 'us_english', 803
execute rdt.rdtAddMsg 158555, 10, '158555INS Log fail  ', 'us_english', 803
execute rdt.rdtAddMsg 158556, 10, '158566Wrong Cart    ', 'us_english', 803
execute rdt.rdtAddMsg 158557, 10, '158577Cart >1 Wave',   'us_english', 803
execute rdt.rdtAddMsg 158558, 10, '158578DropID >1 Wave', 'us_english', 803
execute rdt.rdtAddMsg 158559, 10, '158579Differenr Wave', 'us_english', 803
execute rdt.rdtAddMsg 158580, 10, '158580Differenr Wave', 'us_english', 803


SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE message_id BETWEEN 158551 AND 158600
