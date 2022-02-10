--rdt_1764CreateTask07
rdt.rdtDropMsg 167751 , 167800	

execute rdt.rdtAddMsg 167751, 10, '167751 nspg_getkey  ',   'us_english', 1764
execute rdt.rdtAddMsg 167752, 10, '167752InsTaskDetFail',   'us_english', 1764

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 167751 AND 167800