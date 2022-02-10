--rdt_1819ExtVal06
rdt.rdtDropMsg 138501 , 138550	

execute rdt.rdtAddMsg 138501, 10, '38501^Loc Not Match',    'us_english', 1819
execute rdt.rdtAddMsg 138502, 10, '38502^Invalid ToLoc',    'us_english', 1819


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 138501 AND 138550