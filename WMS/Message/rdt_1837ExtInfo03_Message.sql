--rdt_1837ExtInfo01
rdt.rdtDropMsg 180031 , 180040

execute rdt.rdtAddMsg 180031, 10, 'Last Carton For This',   'us_english', 1837
execute rdt.rdtAddMsg 180032, 10, 'WaveKey ',               'us_english', 1837
execute rdt.rdtAddMsg 180033, 10, 'LoadKey ',               'us_english', 1837
execute rdt.rdtAddMsg 180034, 10, 'ConsigneeKey ',               'us_english', 1837

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 180031 AND 180040