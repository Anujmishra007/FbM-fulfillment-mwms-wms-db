-- rdt_823DataCapture01
exec rdt.rdtDropMsg 103351 , 103400

execute rdt.rdtAddMsg 103351 ,10, '03351^INSERT FAIL',   'us_english', 823
execute rdt.rdtAddMsg 103352 ,10, '03352^UPDATE FAIL',   'us_english', 823

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID BETWEEN 103351 AND 103400