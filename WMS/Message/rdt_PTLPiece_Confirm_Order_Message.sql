-- rdt_PTLPiece_Confirm_Order
execute rdt.rdtDropMsg 99751, 99800

execute rdt.rdtAddMsg 99751, 10, '99751^No order      ', 'us_english', 803
execute rdt.rdtAddMsg 99752, 10, '99752^UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 99753, 10, '99753^nspg_GetKey   ', 'us_english', 803
execute rdt.rdtAddMsg 99754, 10, '99754^INS PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 99755, 10, '99755^INS RefKeyFail', 'us_english', 803
execute rdt.rdtAddMsg 99756, 10, '99756^UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 99757, 10, '99757^UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 99758, 10, '99758^UPD PTask Fail', 'us_english', 803
