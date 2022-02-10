--rdt_PTLPiece_Confirm_Load01
rdt.rdtDropMsg 155101 , 155150

execute rdt.rdtAddMsg 155101, 10, '55101^UPD PKDtl Fail',   'us_english', 803
execute rdt.rdtAddMsg 155102, 10, '55102^nspg_GetKey',      'us_english', 803
execute rdt.rdtAddMsg 155103, 10, '55103^INS PKDtl Fail',   'us_english', 803
execute rdt.rdtAddMsg 155104, 10, '55104^INS RefKeyFail',   'us_english', 803
execute rdt.rdtAddMsg 155105, 10, '55105^UPD PKDtl Fail',   'us_english', 803
execute rdt.rdtAddMsg 155106, 10, '55106^Nothing 2 Sort',   'us_english', 803

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 155101 AND 155150