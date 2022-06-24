--rdt_PTLPiece_Confirm_Order13

execute rdt.rdtDropMsg 187801 , 187850

execute rdt.rdtAddMsg 187801, 10, '187801Light NotPress', 'us_english', 803
execute rdt.rdtAddMsg 187802, 10, '187802^No order     ', 'us_english', 803
execute rdt.rdtAddMsg 187803, 10, '187803^INS PTL Fail ', 'us_english', 803
execute rdt.rdtAddMsg 187804, 10, '187804UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 187805, 10, '187805UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 187806, 10, '187806^nspg_GetKey  ', 'us_english', 803
execute rdt.rdtAddMsg 187807, 10, '187807INS PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 187808, 10, '187808INS RefKeyFail', 'us_english', 803
execute rdt.rdtAddMsg 187809, 10, '187809UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 187810, 10, '187810UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 187811, 10, '187811NoPos4NewOrder', 'us_english', 803
execute rdt.rdtAddMsg 187812, 10, '187812^INS LOG Fail ', 'us_english', 803
execute rdt.rdtAddMsg 187813, 10, '187813^UPD PLog Fail', 'us_english', 803
execute rdt.rdtAddMsg 187814, 10, '187814^INS PTL Fail ', 'us_english', 803
execute rdt.rdtAddMsg 187815, 10, '187815^DEL LOG Fail ', 'us_english', 803
execute rdt.rdtAddMsg 187816, 10, '187816^OderCompleted', 'us_english', 803


SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 187801 and 187850
