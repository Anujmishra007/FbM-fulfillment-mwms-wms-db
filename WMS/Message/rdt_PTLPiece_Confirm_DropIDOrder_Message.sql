-- rdt_PTLPiece_Confirm_DropIDOrder
execute rdt.rdtDropMsg 200051, 200100

execute rdt.rdtAddMsg 200051, 10, '200051No order       ',   'us_english', 803
execute rdt.rdtAddMsg 200052, 10, '200052UPD PKDtl Fail ',   'us_english', 803
execute rdt.rdtAddMsg 200053, 10, '200053nspg_GetKey    ',   'us_english', 803
execute rdt.rdtAddMsg 200054, 10, '200054INS PKDtl Fail ',   'us_english', 803
execute rdt.rdtAddMsg 200055, 10, '200055INS RefKeyFail ',   'us_english', 803
execute rdt.rdtAddMsg 200056, 10, '200056UPD PKDtl Fail ',   'us_english', 803
execute rdt.rdtAddMsg 200057, 10, '200057DEL Log Fail   ',   'us_english', 803
execute rdt.rdtAddMsg 200058, 10, 'ORDER COMPLETED      ',   'us_english', 803
