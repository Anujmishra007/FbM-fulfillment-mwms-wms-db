--rdt_1764CreateTask06
rdt.rdtDropMsg 162951 , 163000	

execute rdt.rdtAddMsg 162951, 10, '62951^Get PA LOC Err',   'us_english', 1764
execute rdt.rdtAddMsg 162952, 10, '62952^NO PA LOC',        'us_english', 1764
execute rdt.rdtAddMsg 162953, 10, '62953^nspg_getkey',      'us_english', 1764
execute rdt.rdtAddMsg 162954, 10, '62954^InsTaskDetFail',   'us_english', 1764
execute rdt.rdtAddMsg 162955, 10, '62955^UpdPKDropIDErr',   'us_english', 1764

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 162951 AND 163000