-- rdt_823ExtUpd02
execute rdt.rdtDropMsg 186251 , 186300

execute rdt.rdtAddMsg 186251, 10, '186251 DELETE FAIL',   'us_english', 823
execute rdt.rdtAddMsg 186252, 10, '186252 INSERT FAIL',   'us_english', 823
execute rdt.rdtAddMsg 186253, 10, '186253 INSERT FAIL',   'us_english', 823

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID BETWEEN 186251 AND 186300