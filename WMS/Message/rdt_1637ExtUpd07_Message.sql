--rdt_1637ExtUpd07
rdt.rdtDropMsg 164351 , 164400	

execute rdt.rdtAddMsg 164351, 10, '64351^Upd MBOL Fail',   'us_english', 1637
execute rdt.rdtAddMsg 164352, 10, '64352^Upd ConDtl Fail', 'us_english', 1637

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 164351 AND 164400