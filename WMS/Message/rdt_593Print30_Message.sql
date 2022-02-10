-- rdt_593Print30
exec rdt.rdtDropMsg 158951, 159000	

execute rdt.rdtAddMsg 158951 ,10, '158951Need orderkey  ', 'us_english', 593
execute rdt.rdtAddMsg 158952 ,10, '158952Inv OrderKey   ', 'us_english', 593
execute rdt.rdtAddMsg 158953 ,10, '158953Inv cartonno   ', 'us_english', 593
execute rdt.rdtAddMsg 158954 ,10, '158954PTL No Manifest', 'us_english', 593
execute rdt.rdtAddMsg 158955 ,10, '158955Setup FilePath ', 'us_english', 593
execute rdt.rdtAddMsg 158956 ,10, '158956Setup FilePath ', 'us_english', 593

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 158951 AND 159000	
