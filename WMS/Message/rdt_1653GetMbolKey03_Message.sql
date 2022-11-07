--rdt_1653GetMbolKey03
exec rdt.rdtDropMsg 191451 , 191500	

execute rdt.rdtAddMsg 191451, 10, '191451 MBOL SHIPPED ',   'us_english', 1653

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 191451 AND 191500

