--rdt_593Print34
exec rdt.rdtDropMsg 173201 , 173250	

execute rdt.rdtAddMsg 173201 ,10, '173201 Need CartonID',  'us_english',593
execute rdt.rdtAddMsg 173202 ,10, '173202 Inv Carton ID',  'us_english',593

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 173201 AND 173250
