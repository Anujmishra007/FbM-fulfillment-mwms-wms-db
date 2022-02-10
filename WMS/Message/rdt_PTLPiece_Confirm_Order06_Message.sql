--rdt_PTLPiece_Confirm_Order06

execute rdt.rdtDropMsg 170951, 171000

execute rdt.rdtAddMsg 170951, 10, '170951Light NotPress', 'us_english', 803
execute rdt.rdtAddMsg 170952, 10, '170952^No order     ', 'us_english', 803
execute rdt.rdtAddMsg 170953, 10, '170953^INS PTL Fail ', 'us_english', 803
execute rdt.rdtAddMsg 170954, 10, '170954UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 170955, 10, '170955UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 170956, 10, '170956^nspg_GetKey  ', 'us_english', 803
execute rdt.rdtAddMsg 170957, 10, '170957INS PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 170958, 10, '170958INS RefKeyFail', 'us_english', 803
execute rdt.rdtAddMsg 170959, 10, '170959UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 170960, 10, '170960UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 170961, 10, '170961NoPos4NewOrder', 'us_english', 803
execute rdt.rdtAddMsg 170962, 10, '170962^INS LOG Fail ', 'us_english', 803
execute rdt.rdtAddMsg 170963, 10, '170963^UPD PLog Fail', 'us_english', 803
execute rdt.rdtAddMsg 170964, 10, '170964^INS PTL Fail ', 'us_english', 803
execute rdt.rdtAddMsg 170965, 10, '170965^DEL LOG Fail ', 'us_english', 803
execute rdt.rdtAddMsg 170966, 10, '170966^OderCompleted', 'us_english', 803


SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 170951 and 171000
