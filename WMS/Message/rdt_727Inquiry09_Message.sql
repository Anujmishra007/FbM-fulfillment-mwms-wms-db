-- rdt_727Inquiry09
execute rdt.rdtDropMsg 169951, 170000

execute rdt.rdtAddMsg 169951, 10, '169951Need CaseID   ', 'us_english', 727
execute rdt.rdtAddMsg 169952, 10, '169952Invalid CaseID', 'us_english', 727


SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 169951 AND 170000

