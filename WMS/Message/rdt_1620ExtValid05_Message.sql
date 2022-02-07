-- rdt_1620ExtValid05
exec rdt.rdtDropMsg 131051 , 131100	

execute rdt.rdtAddMsg 131051 ,10, '31051^Duplicate ID  ',    'us_english', 1620

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 131051 AND 131100	
