-- rdt_PTLPiece_Confirm_Order01
execute rdt.rdtDropMsg 103551, 103600

execute rdt.rdtAddMsg 103551, 10, '103551No order      ', 'us_english', 803
execute rdt.rdtAddMsg 103552, 10, '103552NoPos4NewOrder', 'us_english', 803
execute rdt.rdtAddMsg 103553, 10, '103553INS Log fail  ', 'us_english', 803
execute rdt.rdtAddMsg 103554, 10, '103554Assign Carton ', 'us_english', 803
execute rdt.rdtAddMsg 103555, 10, '103555Light NotPress', 'us_english', 803
execute rdt.rdtAddMsg 103556, 10, '103556UPD PLog Fail ', 'us_english', 803
