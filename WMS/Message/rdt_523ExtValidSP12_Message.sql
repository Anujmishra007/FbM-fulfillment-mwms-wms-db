--rdt_523ExtValidSP12
rdt.rdtDropMsg 203501 , 203550	

execute rdt.rdtAddMsg 203501, 10, '203501 Loc Not Match',    'us_english', 523
execute rdt.rdtAddMsg 203502, 10, '203502 Invalid ToLoc',    'us_english', 523


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 203501 AND 203550