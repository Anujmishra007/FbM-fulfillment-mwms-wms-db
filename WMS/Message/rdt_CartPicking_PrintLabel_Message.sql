-- rdt_CartPicking_PrintLabel
rdt.rdtDropMsg 150651 , 150700	

execute rdt.rdtAddMsg 150651, 10, '150651^NO TASK FOUND',      'us_english', 646
execute rdt.rdtAddMsg 150652, 10, '150652^LOCK TASK FAIL',     'us_english', 646

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 150651 AND 150700	
