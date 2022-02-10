--rdt_593Print22
exec rdt.rdtDropMsg 129251 , 129300	

execute rdt.rdtAddMsg 129251 ,10, '29251^Need Value',    'us_english',593
execute rdt.rdtAddMsg 129252 ,10, '29252^Inv OrderKey',  'us_english',593
execute rdt.rdtAddMsg 129253 ,10, '29253^Inv Track #',   'us_english',593
execute rdt.rdtAddMsg 129254 ,10, '29254^No Record',     'us_english',593

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 129251 AND 129300	
