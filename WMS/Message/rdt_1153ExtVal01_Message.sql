-- rdt_1153ExtVal01
exec rdt.rdtDropMsg 99951 , 100000

execute rdt.rdtAddMsg 99951 ,10, '99951^NOT ALL INPUT',  'us_english',1153
execute rdt.rdtAddMsg 99952 ,10, '99952^COMPONENTS',     'us_english',1153
execute rdt.rdtAddMsg 99953 ,10, '99953^UNCASED !!',     'us_english',1153
--execute rdt.rdtAddMsg 99954 ,10, '99954^UNCASED QTY',    'us_english',1153
--execute rdt.rdtAddMsg 99955 ,10, '99955^> RELEASED QTY', 'us_english',1153

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID BETWEEN 99901 AND 100000