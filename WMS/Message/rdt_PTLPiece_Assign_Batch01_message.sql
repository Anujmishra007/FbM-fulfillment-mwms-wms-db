

-- rdt_PTLPiece_Assign_Batch01
execute rdt.rdtDropMsg 172301 , 172350

execute rdt.rdtAddMsg 172301, 10, '172301BatchIsBlank', 'us_english', 803
execute rdt.rdtAddMsg 172302, 10, '172302Invalidbatch', 'us_english', 803
execute rdt.rdtAddMsg 172303, 10, '172303INS Log fail', 'us_english', 803
execute rdt.rdtAddMsg 172304, 10, '172304Need CartonID', 'us_english', 803
execute rdt.rdtAddMsg 172305, 10, '172305Invalid Format', 'us_english', 803
execute rdt.rdtAddMsg 172306, 10, '172306CartonAssigned', 'us_english', 803
execute rdt.rdtAddMsg 172307, 10, '172307UPD Log fail', 'us_english', 803


