--rdt_PTLPiece_Confirm_Order11
execute rdt.rdtDropMsg 178401, 178450

execute rdt.rdtAddMsg 178401, 10, '178401 No order     ', 'us_english', 803
execute rdt.rdtAddMsg 178402, 10, '178402UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 178403, 10, '178403 nspg_GetKey  ', 'us_english', 803
execute rdt.rdtAddMsg 178404, 10, '178404INS PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 178405, 10, '178405INS RefKeyFail', 'us_english', 803
execute rdt.rdtAddMsg 178406, 10, '178406UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 178407, 10, '178407UPD PTask Fail', 'us_english', 803

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 178401 AND 178450
