-- rdt_823ExtUpd01 
execute rdt.rdtDropMsg 104651 , 104700

execute rdt.rdtAddMsg 104651, 10, '04651^DELETE FAIL',   'us_english', 823
execute rdt.rdtAddMsg 104652, 10, '04651^INSERT FAIL',   'us_english', 823

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID BETWEEN 104651 AND 104700