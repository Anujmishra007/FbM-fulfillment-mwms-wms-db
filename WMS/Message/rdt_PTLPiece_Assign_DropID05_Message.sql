-- rdt_PTLPiece_Assign_DropID05
execute rdt.rdtDropMsg 187951 , 188000

execute rdt.rdtAddMsg 187951, 10, '187951Need DropID   ', 'us_english', 803
execute rdt.rdtAddMsg 187952, 10, '187952Bad DropID    ', 'us_english', 803
execute rdt.rdtAddMsg 187953, 10, '187953DropIDAssigned', 'us_english', 803
execute rdt.rdtAddMsg 187954, 10, '187954Diff Station  ', 'us_english', 803
execute rdt.rdtAddMsg 187955, 10, '187955Not enuf Pos  ', 'us_english', 803
execute rdt.rdtAddMsg 187956, 10, '187956LogicalNameReq', 'us_english', 803
execute rdt.rdtAddMsg 187957, 10, '187957INS Log fail  ', 'us_english', 803

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 187951 AND 188000