--rdt_941ExtVal01
--FCR-939
execute rdt.rdtDropMsg 225351 , 225400	

execute rdt.rdtAddMsg 225351, 10, '225351^InvalidLoc',         'us_english', 941
execute rdt.rdtAddMsg 225352, 10, '225352^InvalidPKZone',      'us_english', 941

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 225351 AND 225400