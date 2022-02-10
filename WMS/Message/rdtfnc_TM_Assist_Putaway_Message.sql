-- rdtfnc_TM_Assist_Putaway
rdt.rdtDropMsg 51951 , 52000

execute rdt.rdtAddMsg 51951, 10, '51951^LOC needed    ',    'us_english', 1815
execute rdt.rdtAddMsg 51952, 10, '51952^Invalid LOC   ',    'us_english', 1815
execute rdt.rdtAddMsg 51953, 10, '51953^LOC Not Match ',    'us_english', 1815
execute rdt.rdtAddMsg 51954, 10, '51954^Option req    ',    'us_english', 1815
execute rdt.rdtAddMsg 51955, 10, '51955^Invalid Option',    'us_english', 1815
execute rdt.rdtAddMsg 51956, 10, '51956^NextTaskFncErr',    'us_english', 1815
execute rdt.rdtAddMsg 51957, 10, '51957^NextTaskScnErr',    'us_english', 1815


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 51951 AND 52000