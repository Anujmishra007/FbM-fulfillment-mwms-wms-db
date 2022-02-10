--rdt_841ExtValidSP03
rdt.rdtDropMsg 147301 , 147350	

execute rdt.rdtAddMsg 147301, 10, '47301^WRONG ORD TYPE',  'us_english', 841
execute rdt.rdtAddMsg 147302, 10, '47302^WRONG ORD TYPE',  'us_english', 841


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 147301 AND 147350	