-- rdt_PTLPiece_Confirm_BatchOrder
execute rdt.rdtDropMsg 194401, 194450

execute rdt.rdtAddMsg 194401, 10, '194401No order      ', 'us_english', 803
execute rdt.rdtAddMsg 194402, 10, '194402NoPos4NewOrder', 'us_english', 803
execute rdt.rdtAddMsg 194403, 10, '194403INS Log fail  ', 'us_english', 803
execute rdt.rdtAddMsg 194404, 10, '194404Assign Carton ', 'us_english', 803
execute rdt.rdtAddMsg 194405, 10, '194405UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 194406, 10, '194406nspg_GetKey   ', 'us_english', 803
execute rdt.rdtAddMsg 194407, 10, '194407INS PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 194408, 10, '194408INS RefKeyFail', 'us_english', 803
execute rdt.rdtAddMsg 194409, 10, '194409UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 194410, 10, '194410UPD PTask Fail', 'us_english', 803
execute rdt.rdtAddMsg 194410, 10, '194410DEL Log Fail  ', 'us_english', 803
