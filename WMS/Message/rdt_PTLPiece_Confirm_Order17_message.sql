-- rdt_PTLPiece_Confirm_Order17
execute rdt.rdtDropMsg 200101, 200150

execute rdt.rdtAddMsg  200101, 10, ' 200101No order      ', 'us_english', 803
execute rdt.rdtAddMsg  200102, 10, ' 200102UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg  200103, 10, ' 200103nspg_GetKey   ', 'us_english', 803
execute rdt.rdtAddMsg  200104, 10, ' 200104INS PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg  200105, 10, ' 200105INS RefKeyFail', 'us_english', 803
execute rdt.rdtAddMsg  200106, 10, ' 200106UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg  200107, 10, ' 200107UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg  200108, 10, ' 200108UPD PTask Fail', 'us_english', 803
