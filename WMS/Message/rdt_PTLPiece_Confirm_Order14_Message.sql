-- rdt_PTLPiece_Confirm_Order14
execute rdt.rdtDropMsg 188051 , 188100

execute rdt.rdtAddMsg 188051, 10, '188051No order      ', 'us_english', 803
execute rdt.rdtAddMsg 188052, 10, '188052NoPos4NewOrder', 'us_english', 803
execute rdt.rdtAddMsg 188053, 10, '188053INS Log fail  ', 'us_english', 803
execute rdt.rdtAddMsg 188054, 10, '188054Assign Carton ', 'us_english', 803
execute rdt.rdtAddMsg 188055, 10, '188055UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 188056, 10, '188056nspg_GetKey   ', 'us_english', 803
execute rdt.rdtAddMsg 188057, 10, '188057INS PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 188058, 10, '188058INS RefKeyFail', 'us_english', 803
execute rdt.rdtAddMsg 188059, 10, '188059UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 188060, 10, '188060UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 188061, 10, '188061DEL Log Fail  ', 'us_english', 803
execute rdt.rdtAddMsg 188062, 10, 'ORDER COMPLETED     ', 'us_english', 803
execute rdt.rdtAddMsg 188063, 10, '188063Scan-Out Fail ', 'us_english', 803
execute rdt.rdtAddMsg 188064, 10, '188064Scan-Out Fail ', 'us_english', 803
execute rdt.rdtAddMsg 188065, 10, '188065 SKU Not In ID', 'us_english', 803

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 188051 AND 188100