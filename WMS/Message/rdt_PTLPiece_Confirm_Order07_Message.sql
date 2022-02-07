--rdt_PTLPiece_Confirm_Order07

execute rdt.rdtDropMsg 173601, 173650

execute rdt.rdtAddMsg 173601, 10, '173601^No order     ', 'us_english', 803
execute rdt.rdtAddMsg 173602, 10, '173602UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 173603, 10, '173603^nspg_GetKey  ', 'us_english', 803
execute rdt.rdtAddMsg 173604, 10, '173604^INS PKDtlFail', 'us_english', 803
execute rdt.rdtAddMsg 173605, 10, '173605^INSRefKeyFail', 'us_english', 803
execute rdt.rdtAddMsg 173606, 10, '173606^UPD PKDtlFail', 'us_english', 803
execute rdt.rdtAddMsg 173607, 10, '173607NoPos4NewOrder', 'us_english', 803
execute rdt.rdtAddMsg 173608, 10, '173608^INS Log fail ', 'us_english', 803
execute rdt.rdtAddMsg 173609, 10, '173609^INS PTL Fail ', 'us_english', 803


SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 173601 and 173650
