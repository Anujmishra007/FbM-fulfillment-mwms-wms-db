--rdt_803ExtUpd03
rdt.rdtDropMsg 183601 , 183650		

execute rdt.rdtAddMsg 183601, 10, '183601UPD PKDtl Fail',    'us_english', 803

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 183601 AND 183650	