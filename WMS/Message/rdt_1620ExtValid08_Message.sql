--rdt_1620ExtValid08
exec rdt.rdtDropMsg 154951 , 155000

execute rdt.rdtAddMsg 154951 ,10, '54951^LoadPickMtd=C',    'us_english', 1620
execute rdt.rdtAddMsg 154952 ,10, '54952^LoadPickMtd=C',    'us_english', 1620

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 154951 AND 155000