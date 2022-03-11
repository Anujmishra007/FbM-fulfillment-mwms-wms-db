-- rdt_839ExtUpd04
rdt.rdtDropMsg 183551 , 183600		

execute rdt.rdtAddMsg 183551, 10, '183551UPD PKDtl Fail',    'us_english', 839

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 183551 AND 183600	