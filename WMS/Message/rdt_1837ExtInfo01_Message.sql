--rdt_1837ExtInfo01
rdt.rdtDropMsg 145601 , 145650

execute rdt.rdtAddMsg 145601, 10, 'Last Carton For This',   'us_english', 1837
execute rdt.rdtAddMsg 145602, 10, 'LoadKey ',               'us_english', 1837

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 145601 AND 145650