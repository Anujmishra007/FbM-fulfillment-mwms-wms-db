--rdt_1638ExtVal15
exec rdt.rdtdropmsg 187451 , 187500	

execute rdt.rdtAddMsg 187451, 10, '187451 PALLET CLOSED', 'us_english', 1638
execute rdt.rdtAddMsg 187452, 10, '187452 NEED TRACKNO ', 'us_english', 1638
execute rdt.rdtAddMsg 187453, 10, '187453 TRACKNO EXIST', 'us_english', 1638
execute rdt.rdtAddMsg 187454, 10, '187453 SCAN ALL CASE', 'us_english', 1638

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 187451 AND 187500
